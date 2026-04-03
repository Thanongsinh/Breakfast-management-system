package services

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// BuildingService defines methods for building business logic
type BuildingService interface {
	Create(ctx context.Context, building *entities.Building) error
	GetByID(ctx context.Context, id string) (*entities.Building, error)
	Update(ctx context.Context, building *entities.Building) error
	Delete(ctx context.Context, id string) error
	ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Building, error)
}

// buildingServiceImpl is the concrete implementation of BuildingService
type buildingServiceImpl struct {
	// TODO: add dependencies (building repository)
}

// NewBuildingService creates a new instance of BuildingService
func NewBuildingService() BuildingService {
	return &buildingServiceImpl{}
}

func (s *buildingServiceImpl) Create(ctx context.Context, building *entities.Building) error {
	// TODO: implement
	return nil
}

func (s *buildingServiceImpl) GetByID(ctx context.Context, id string) (*entities.Building, error) {
	// TODO: implement
	return nil, nil
}

func (s *buildingServiceImpl) Update(ctx context.Context, building *entities.Building) error {
	// TODO: implement
	return nil
}

func (s *buildingServiceImpl) Delete(ctx context.Context, id string) error {
	// TODO: implement
	return nil
}

func (s *buildingServiceImpl) ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Building, error) {
	// TODO: implement
	return nil, nil
}
