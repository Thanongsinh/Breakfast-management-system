package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"rental-v3/backend/bootstrap"
)

type NotificationService struct {
	config *bootstrap.Config
}

func NewNotificationService(config *bootstrap.Config) *NotificationService {
	return &NotificationService{
		config: config,
	}
}

// SendLINENotify sends a LINE notification message
func (s *NotificationService) SendLINENotify(message string) error {
	if s.config.LINE.NotifyToken == "" {
		return fmt.Errorf("LINE notify token not configured")
	}

	url := "https://notify-api.line.me/api/notify"

	// Create form data
	data := map[string]string{
		"message": message,
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	// Create request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.config.LINE.NotifyToken)

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to send LINE notification: status %d", resp.StatusCode)
	}

	return nil
}

// SendBillReminder sends a bill reminder to a tenant
func (s *NotificationService) SendBillReminder(tenantName string, billAmount float64, dueDate string) error {
	message := fmt.Sprintf(
		"📢 Bill Reminder\n\nDear %s,\n\nYour bill of %.2f THB is due on %s.\nPlease make payment at the office.\n\nThank you!",
		tenantName,
		billAmount,
		dueDate,
	)
	return s.SendLINENotify(message)
}

// SendPaymentConfirmation sends a payment confirmation to a tenant
func (s *NotificationService) SendPaymentConfirmation(tenantName string, amount float64, receiptPath string) error {
	message := fmt.Sprintf(
		"✅ Payment Confirmed\n\nDear %s,\n\nYour payment of %.2f THB has been confirmed.\n\nReceipt: %s\n\nThank you!",
		tenantName,
		amount,
		receiptPath,
	)
	return s.SendLINENotify(message)
}
