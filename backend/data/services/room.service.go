package services

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// RoomService defines methods for room business logic
type RoomService interface {
	Create(ctx context.Context, room *entities.Room) error
	GetByID(ctx context.Context, id string) (*entities.Room, error)
	Update(ctx context.Context, room *entities.Room) error
	Delete(ctx context.Context, id string) error
	ListByBuilding(ctx context.Context, buildingID string) ([]*entities.Room, error)
	UpdateStatus(ctx context.Context, id string, status string) error
}

// roomServiceImpl is the concrete implementation of RoomService
type roomServiceImpl struct {
	// TODO: add dependencies (room repository)
}

// NewRoomService creates a new instance of RoomService
func NewRoomService() RoomService {
	return &roomServiceImpl{}
}

func (s *roomServiceImpl) Create(ctx context.Context, room *entities.Room) error {
	// TODO: implement
	return nil
}

func (s *roomServiceImpl) GetByID(ctx context.Context, id string) (*entities.Room, error) {
	// TODO: implement
	return nil, nil
}

func (s *roomServiceImpl) Update(ctx context.Context, room *entities.Room) error {
	// TODO: implement
	return nil
}

func (s *roomServiceImpl) Delete(ctx context.Context, id string) error {
	// TODO: implement
	return nil
}

func (s *roomServiceImpl) ListByBuilding(ctx context.Context, buildingID string) ([]*entities.Room, error) {
	// TODO: implement
	return nil, nil
}

func (s *roomServiceImpl) UpdateStatus(ctx context.Context, id string, status string) error {
	// TODO: implement
	return nil
}
