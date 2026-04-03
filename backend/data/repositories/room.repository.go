package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// RoomRepository defines methods for room data access
type RoomRepository interface {
	Create(ctx context.Context, room *entities.Room) error
	FindByID(ctx context.Context, id string) (*entities.Room, error)
	Update(ctx context.Context, room *entities.Room) error
	Delete(ctx context.Context, id string) error
	ListByBuilding(ctx context.Context, buildingID string) ([]*entities.Room, error)
	UpdateStatus(ctx context.Context, id string, status string) error
}

// roomRepositoryImpl is the concrete implementation of RoomRepository
type roomRepositoryImpl struct {
	// TODO: add database connection
}

// NewRoomRepository creates a new instance of RoomRepository
func NewRoomRepository() RoomRepository {
	return &roomRepositoryImpl{}
}

func (r *roomRepositoryImpl) Create(ctx context.Context, room *entities.Room) error {
	// TODO: implement
	return nil
}

func (r *roomRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.Room, error) {
	// TODO: implement
	return nil, nil
}

func (r *roomRepositoryImpl) Update(ctx context.Context, room *entities.Room) error {
	// TODO: implement
	return nil
}

func (r *roomRepositoryImpl) Delete(ctx context.Context, id string) error {
	// TODO: implement
	return nil
}

func (r *roomRepositoryImpl) ListByBuilding(ctx context.Context, buildingID string) ([]*entities.Room, error) {
	// TODO: implement
	return nil, nil
}

func (r *roomRepositoryImpl) UpdateStatus(ctx context.Context, id string, status string) error {
	// TODO: implement
	return nil
}
