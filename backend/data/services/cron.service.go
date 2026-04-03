package services

import (
	"fmt"
	"rental-v3/backend/bootstrap"
	"rental-v3/backend/core/logs"
	"time"

	"github.com/robfig/cron/v3"
	"go.uber.org/zap"
)

type CronService struct {
	billService         *BillService
	notificationService *NotificationService
	config              *bootstrap.Config
	cron                *cron.Cron
}

func NewCronService(
	billService *BillService,
	notificationService *NotificationService,
	config *bootstrap.Config,
) *CronService {
	return &CronService{
		billService:         billService,
		notificationService: notificationService,
		config:              config,
		cron:                cron.New(),
	}
}

// Setup sets up all cron jobs
func (s *CronService) Setup() *cron.Cron {
	// Monthly bill generation (e.g., "0 0 1 * *" = At 00:00 on day-of-month 1)
	if s.config.Cron.BillGenerate != "" {
		_, err := s.cron.AddFunc(s.config.Cron.BillGenerate, func() {
			s.generateMonthlyBills()
		})
		if err != nil {
			logs.Logger.Error("Failed to schedule bill generation", zap.Error(err))
		} else {
			logs.Logger.Info("Scheduled bill generation", zap.String("schedule", s.config.Cron.BillGenerate))
		}
	}

	// First payment reminder (e.g., "0 9 25 * *" = At 09:00 on day-of-month 25)
	if s.config.Cron.ReminderFirst != "" {
		_, err := s.cron.AddFunc(s.config.Cron.ReminderFirst, func() {
			s.sendFirstReminders()
		})
		if err != nil {
			logs.Logger.Error("Failed to schedule first reminders", zap.Error(err))
		} else {
			logs.Logger.Info("Scheduled first reminders", zap.String("schedule", s.config.Cron.ReminderFirst))
		}
	}

	// Final payment reminder (e.g., "0 9 28 * *" = At 09:00 on day-of-month 28)
	if s.config.Cron.ReminderFinal != "" {
		_, err := s.cron.AddFunc(s.config.Cron.ReminderFinal, func() {
			s.sendFinalReminders()
		})
		if err != nil {
			logs.Logger.Error("Failed to schedule final reminders", zap.Error(err))
		} else {
			logs.Logger.Info("Scheduled final reminders", zap.String("schedule", s.config.Cron.ReminderFinal))
		}
	}

	return s.cron
}

// generateMonthlyBills generates bills for all active contracts
func (s *CronService) generateMonthlyBills() {
	now := time.Now()
	month := int(now.Month())
	year := now.Year()

	logs.Logger.Info("Starting monthly bill generation",
		zap.Int("month", month),
		zap.Int("year", year))

	err := s.billService.GenerateBills(month, year)
	if err != nil {
		logs.Logger.Error("Failed to generate monthly bills",
			zap.Error(err),
			zap.Int("month", month),
			zap.Int("year", year))
		return
	}

	logs.Logger.Info("Successfully generated monthly bills",
		zap.Int("month", month),
		zap.Int("year", year))

	// Send notifications to tenants about new bills
	message := fmt.Sprintf("📢 New bill generated for %s %d. Please check your bill and make payment before the due date.", now.Month().String(), year)
	s.notificationService.SendLINENotify(message)
}

// sendFirstReminders sends first payment reminders to tenants with unpaid bills
func (s *CronService) sendFirstReminders() {
	logs.Logger.Info("Sending first payment reminders")

	message := "⏰ Payment Reminder: Your bill is due soon. Please make payment at the office to avoid late fees."
	err := s.notificationService.SendLINENotify(message)
	if err != nil {
		logs.Logger.Error("Failed to send first reminders", zap.Error(err))
		return
	}

	logs.Logger.Info("Successfully sent first payment reminders")
}

// sendFinalReminders sends final payment reminders to tenants with unpaid bills
func (s *CronService) sendFinalReminders() {
	logs.Logger.Info("Sending final payment reminders")

	message := "🚨 URGENT: Final payment reminder! Your bill is due very soon. Please make immediate payment to avoid penalties."
	err := s.notificationService.SendLINENotify(message)
	if err != nil {
		logs.Logger.Error("Failed to send final reminders", zap.Error(err))
		return
	}

	logs.Logger.Info("Successfully sent final payment reminders")
}

// Start starts the cron scheduler
func (s *CronService) Start() {
	s.cron.Start()
	logs.Logger.Info("Cron service started")
}

// Stop stops the cron scheduler
func (s *CronService) Stop() {
	s.cron.Stop()
	logs.Logger.Info("Cron service stopped")
}
