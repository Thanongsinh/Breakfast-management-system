package services

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// PaymentService defines methods for payment business logic
type PaymentService interface {
	ConfirmCashPayment(ctx context.Context, payment *entities.Payment) error
	GetByID(ctx context.Context, id string) (*entities.Payment, error)
	List(ctx context.Context, limit, offset int) ([]*entities.Payment, error)
}

// paymentServiceImpl is the concrete implementation of PaymentService
type paymentServiceImpl struct {
	// TODO: add dependencies (payment repository, bill repository)
}

// NewPaymentService creates a new instance of PaymentService
func NewPaymentService() PaymentService {
	return &paymentServiceImpl{}
}

func (s *paymentServiceImpl) ConfirmCashPayment(ctx context.Context, payment *entities.Payment) error {
	// TODO: implement
	return nil
}

func (s *paymentServiceImpl) GetByID(ctx context.Context, id string) (*entities.Payment, error) {
	// TODO: implement
	return nil, nil
}

func (s *paymentServiceImpl) List(ctx context.Context, limit, offset int) ([]*entities.Payment, error) {
	// TODO: implement
	return nil, nil
}
