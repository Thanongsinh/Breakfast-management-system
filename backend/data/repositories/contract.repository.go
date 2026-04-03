package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// ContractRepository defines methods for contract data access
type ContractRepository interface {
	Create(ctx context.Context, contract *entities.Contract) error
	FindByID(ctx context.Context, id string) (*entities.Contract, error)
	FindActiveByTenant(ctx context.Context, tenantID string) (*entities.Contract, error)
	Update(ctx context.Context, contract *entities.Contract) error
	List(ctx context.Context, limit, offset int) ([]*entities.Contract, error)
}

// contractRepositoryImpl is the concrete implementation of ContractRepository
type contractRepositoryImpl struct {
	// TODO: add database connection
}

// NewContractRepository creates a new instance of ContractRepository
func NewContractRepository() ContractRepository {
	return &contractRepositoryImpl{}
}

func (r *contractRepositoryImpl) Create(ctx context.Context, contract *entities.Contract) error {
	// TODO: implement
	return nil
}

func (r *contractRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Contract, error) {
	// TODO: implement
	return nil, nil
}

func (r *contractRepositoryImpl) FindActiveByTenant(ctx context.Context, tenantID string) (*entities.Contract, error) {
	// TODO: implement
	return nil, nil
}

func (r *contractRepositoryImpl) Update(ctx context.Context, contract *entities.Contract) error {
	// TODO: implement
	return nil
}

func (r *contractRepositoryImpl) List(ctx context.Context, limit, offset int) ([]*entities.Contract, error) {
	// TODO: implement
	return nil, nil
}
