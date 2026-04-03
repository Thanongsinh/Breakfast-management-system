package services

import (
	"context"
	"rental-v3/backend/domain/entities"
	"time"
)

// BillService defines methods for bill business logic
type BillService interface {
	GenerateBills(ctx context.Context, ownerID string, month time.Time) error
	CreateBill(ctx context.Context, bill *entities.Bill) error
	GetByID(ctx context.Context, id string) (*entities.Bill, error)
	ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.Bill, error)
	ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Bill, error)
}

// billServiceImpl is the concrete implementation of BillService
type billServiceImpl struct {
	// TODO: add dependencies (bill repository, contract repository)
}

// NewBillService creates a new instance of BillService
func NewBillService() BillService {
	return &billServiceImpl{}
}

func (s *billServiceImpl) GenerateBills(ctx context.Context, ownerID string, month time.Time) error {
	// TODO: implement
	return nil
}

func (s *billServiceImpl) CreateBill(ctx context.Context, bill *entities.Bill) error {
	// TODO: implement
	return nil
}

func (s *billServiceImpl) GetByID(ctx context.Context, id string) (*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}

func (s *billServiceImpl) ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}

func (s *billServiceImpl) ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}
