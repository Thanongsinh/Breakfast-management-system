package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// BillRepository defines methods for bill data access
type BillRepository interface {
	Create(ctx context.Context, bill *entities.Bill) error
	FindByID(ctx context.Context, id string) (*entities.Bill, error)
	Update(ctx context.Context, bill *entities.Bill) error
	ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.Bill, error)
	ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Bill, error)
	ListUnpaid(ctx context.Context, ownerID string) ([]*entities.Bill, error)
}

// billRepositoryImpl is the concrete implementation of BillRepository
type billRepositoryImpl struct {
	// TODO: add database connection
}

// NewBillRepository creates a new instance of BillRepository
func NewBillRepository() BillRepository {
	return &billRepositoryImpl{}
}

func (r *billRepositoryImpl) Create(ctx context.Context, bill *entities.Bill) error {
	// TODO: implement
	return nil
}

func (r *billRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}

func (r *billRepositoryImpl) Update(ctx context.Context, bill *entities.Bill) error {
	// TODO: implement
	return nil
}

func (r *billRepositoryImpl) ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}

func (r *billRepositoryImpl) ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}

func (r *billRepositoryImpl) ListUnpaid(ctx context.Context, ownerID string) ([]*entities.Bill, error) {
	// TODO: implement
	return nil, nil
}
