package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// PaymentRepository defines methods for payment data access
type PaymentRepository interface {
	Create(ctx context.Context, payment *entities.Payment) error
	FindByID(ctx context.Context, id string) (*entities.Payment, error)
	FindByBillID(ctx context.Context, billID string) ([]*entities.Payment, error)
	List(ctx context.Context, limit, offset int) ([]*entities.Payment, error)
}

// paymentRepositoryImpl is the concrete implementation of PaymentRepository
type paymentRepositoryImpl struct {
	// TODO: add database connection
}

// NewPaymentRepository creates a new instance of PaymentRepository
func NewPaymentRepository() PaymentRepository {
	return &paymentRepositoryImpl{}
}

func (r *paymentRepositoryImpl) Create(ctx context.Context, payment *entities.Payment) error {
	// TODO: implement
	return nil
}

func (r *paymentRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Payment, error) {
	// TODO: implement
	return nil, nil
}

func (r *paymentRepositoryImpl) FindByBillID(ctx context.Context, billID string) ([]*entities.Payment, error) {
	// TODO: implement
	return nil, nil
}

func (r *paymentRepositoryImpl) List(ctx context.Context, limit, offset int) ([]*entities.Payment, error) {
	// TODO: implement
	return nil, nil
}
