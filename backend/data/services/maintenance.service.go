package services

import (
	"context"
	"io"
	"rental-v3/backend/domain/entities"
)

// MaintenanceService defines methods for maintenance request business logic
type MaintenanceService interface {
	Create(ctx context.Context, maintenance *entities.MaintenanceRequest) error
	GetByID(ctx context.Context, id string) (*entities.MaintenanceRequest, error)
	Update(ctx context.Context, maintenance *entities.MaintenanceRequest) error
	ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.MaintenanceRequest, error)
	ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.MaintenanceRequest, error)
	UploadImages(ctx context.Context, maintenanceID string, images []io.Reader) ([]string, error)
}

// maintenanceServiceImpl is the concrete implementation of MaintenanceService
type maintenanceServiceImpl struct {
	// TODO: add dependencies (maintenance repository, storage service)
}

// NewMaintenanceService creates a new instance of MaintenanceService
func NewMaintenanceService() MaintenanceService {
	return &maintenanceServiceImpl{}
}

func (s *maintenanceServiceImpl) Create(ctx context.Context, maintenance *entities.MaintenanceRequest) error {
	// TODO: implement
	return nil
}

func (s *maintenanceServiceImpl) GetByID(ctx context.Context, id string) (*entities.MaintenanceRequest, error) {
	// TODO: implement
	return nil, nil
}

func (s *maintenanceServiceImpl) Update(ctx context.Context, maintenance *entities.MaintenanceRequest) error {
	// TODO: implement
	return nil
}

func (s *maintenanceServiceImpl) ListByTenant(ctx context.Context, tenantID string, limit, offset int) ([]*entities.MaintenanceRequest, error) {
	// TODO: implement
	return nil, nil
}

func (s *maintenanceServiceImpl) ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.MaintenanceRequest, error) {
	// TODO: implement
	return nil, nil
}

func (s *maintenanceServiceImpl) UploadImages(ctx context.Context, maintenanceID string, images []io.Reader) ([]string, error) {
	// TODO: implement
	return nil, nil
}
