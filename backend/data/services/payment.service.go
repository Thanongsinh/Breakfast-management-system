package services

import (
	"errors"
	"fmt"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
	"time"
)

type PaymentService struct {
	paymentRepo         *repositories.PaymentRepository
	billRepo            *repositories.BillRepository
	tenantRepo          *repositories.TenantRepository
	storageService      StorageService
	notificationService *NotificationService
}

func NewPaymentService(
	paymentRepo *repositories.PaymentRepository,
	billRepo *repositories.BillRepository,
	tenantRepo *repositories.TenantRepository,
	storageService StorageService,
	notificationService *NotificationService,
) *PaymentService {
	return &PaymentService{
		paymentRepo:         paymentRepo,
		billRepo:            billRepo,
		tenantRepo:          tenantRepo,
		storageService:      storageService,
		notificationService: notificationService,
	}
}

// ConfirmCashPayment confirms a cash payment for a bill
func (s *PaymentService) ConfirmCashPayment(req models.ConfirmCashPaymentRequest, confirmedBy uint) (*entities.Payment, error) {
	// Get bill
	bill, err := s.billRepo.FindByID(req.BillID)
	if err != nil {
		return nil, err
	}

	// Check if bill is already paid
	if bill.Status == "paid" {
		return nil, errors.New("bill is already paid")
	}

	// Create payment record
	payment := &entities.Payment{
		BillID:      req.BillID,
		TenantID:    bill.TenantID,
		Amount:      req.Amount,
		PaidAt:      time.Now(),
		ConfirmedBy: confirmedBy,
		Note:        req.Note,
	}

	if err := s.paymentRepo.Create(payment); err != nil {
		return nil, err
	}

	// Update bill status
	bill.Status = "paid"
	if err := s.billRepo.Update(bill); err != nil {
		return nil, err
	}

	// Generate receipt PDF and send notification asynchronously
	go func() {
		// Generate receipt PDF
		receiptPath := fmt.Sprintf("receipts/receipt-%d-%d.pdf", payment.ID, time.Now().Unix())
		payment.ReceiptPDFPath = receiptPath
		s.paymentRepo.Create(payment) // Update with PDF path

		// Send LINE notification
		tenant, err := s.tenantRepo.FindByID(payment.TenantID)
		if err == nil {
			s.notificationService.SendPaymentConfirmation(tenant.EmergencyContact, payment.Amount, receiptPath)
		}
	}()

	return payment, nil
}

// GetByID gets a payment by ID
func (s *PaymentService) GetByID(id uint) (*entities.Payment, error) {
	return s.paymentRepo.FindByID(id)
}

// List returns paginated payments for an owner
func (s *PaymentService) List(ownerID uint, page, limit int) ([]entities.Payment, int64, error) {
	return s.paymentRepo.List(ownerID, page, limit)
}

// ListByTenant returns paginated payments for a tenant
func (s *PaymentService) ListByTenant(tenantID uint, page, limit int) ([]entities.Payment, int64, error) {
	return s.paymentRepo.ListByTenant(tenantID, page, limit)
}
