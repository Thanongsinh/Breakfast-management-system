package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// BuildingRepository defines methods for building data access
type BuildingRepository interface {
	Create(ctx context.Context, building *entities.Building) error
	FindByID(ctx context.Context, id string) (*entities.Building, error)
	Update(ctx context.Context, building *entities.Building) error
	Delete(ctx context.Context, id string) error
	ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Building, error)
}

// buildingRepositoryImpl is the concrete implementation of BuildingRepository
type buildingRepositoryImpl struct {
	// TODO: add database connection
}

// NewBuildingRepository creates a new instance of BuildingRepository
func NewBuildingRepository() BuildingRepository {
	return &buildingRepositoryImpl{}
}

func (r *buildingRepositoryImpl) Create(ctx context.Context, building *entities.Building) error {
	// TODO: implement
	return nil
}

func (r *buildingRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Building, error) {
	// TODO: implement
	return nil, nil
}

func (r *buildingRepositoryImpl) Update(ctx context.Context, building *entities.Building) error {
	// TODO: implement
	return nil
}

func (r *buildingRepositoryImpl) Delete(ctx context.Context, id string) error {
	// TODO: implement
	return nil
}

func (r *buildingRepositoryImpl) ListByOwner(ctx context.Context, ownerID string, limit, offset int) ([]*entities.Building, error) {
	// TODO: implement
	return nil, nil
}
