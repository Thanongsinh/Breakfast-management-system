package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// TenantRepository defines methods for tenant data access
type TenantRepository interface {
	Create(ctx context.Context, tenant *entities.Tenant) error
	FindByID(ctx context.Context, id string) (*entities.Tenant, error)
	FindByUserID(ctx context.Context, userID string) (*entities.Tenant, error)
	Update(ctx context.Context, tenant *entities.Tenant) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, limit, offset int) ([]*entities.Tenant, error)
}

// tenantRepositoryImpl is the concrete implementation of TenantRepository
type tenantRepositoryImpl struct {
	// TODO: add database connection
}

// NewTenantRepository creates a new instance of TenantRepository
func NewTenantRepository() TenantRepository {
	return &tenantRepositoryImpl{}
}

func (r *tenantRepositoryImpl) Create(ctx context.Context, tenant *entities.Tenant) error {
	// TODO: implement
	return nil
}

func (r *tenantRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Tenant, error) {
	// TODO: implement
	return nil, nil
}

func (r *tenantRepositoryImpl) FindByUserID(ctx context.Context, userID string) (*entities.Tenant, error) {
	// TODO: implement
	return nil, nil
}

func (r *tenantRepositoryImpl) Update(ctx context.Context, tenant *entities.Tenant) error {
	// TODO: implement
	return nil
}

func (r *tenantRepositoryImpl) Delete(ctx context.Context, id string) error {
	// TODO: implement
	return nil
}

func (r *tenantRepositoryImpl) List(ctx context.Context, limit, offset int) ([]*entities.Tenant, error) {
	// TODO: implement
	return nil, nil
}
