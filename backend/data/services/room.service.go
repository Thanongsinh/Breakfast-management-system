package services

import (
	"errors"
	"github.com/lib/pq"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
)

type RoomService struct {
	roomRepo     *repositories.RoomRepository
	buildingRepo *repositories.BuildingRepository
}

func NewRoomService(
	roomRepo *repositories.RoomRepository,
	buildingRepo *repositories.BuildingRepository,
) *RoomService {
	return &RoomService{
		roomRepo:     roomRepo,
		buildingRepo: buildingRepo,
	}
}

// Create creates a new room
func (s *RoomService) Create(ownerID uint, req models.CreateRoomRequest) (*entities.Room, error) {
	// Verify building ownership
	building, err := s.buildingRepo.FindByID(req.BuildingID)
	if err != nil {
		return nil, err
	}
	if building.OwnerID != ownerID {
		return nil, errors.New("forbidden: not the owner of this building")
	}

	// Check if room number already exists in this building
	existingRoom, _ := s.roomRepo.FindByBuildingAndNumber(req.BuildingID, req.Number)
	if existingRoom != nil && existingRoom.ID > 0 {
		return nil, errors.New("room number already exists in this building")
	}

	room := &entities.Room{
		BuildingID: req.BuildingID,
		Number:     req.Number,
		Floor:      req.Floor,
		Type:       req.Type,
		SizeSqm:    req.SizeSqm,
		RentPrice:  req.RentPrice,
		Status:     req.Status,
		Images:     pq.StringArray(req.Images),
	}

	if err := s.roomRepo.Create(room); err != nil {
		return nil, err
	}

	return room, nil
}

// Update updates a room
func (s *RoomService) Update(id, ownerID uint, req models.UpdateRoomRequest) error {
	room, err := s.roomRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership through building
	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}
	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this room")
	}

	// Update fields
	if req.Number != "" {
		room.Number = req.Number
	}
	if req.Floor > 0 {
		room.Floor = req.Floor
	}
	if req.Type != "" {
		room.Type = req.Type
	}
	if req.SizeSqm > 0 {
		room.SizeSqm = req.SizeSqm
	}
	if req.RentPrice > 0 {
		room.RentPrice = req.RentPrice
	}
	if len(req.Images) > 0 {
		room.Images = pq.StringArray(req.Images)
	}

	return s.roomRepo.Update(room)
}

// UpdateStatus updates room status
func (s *RoomService) UpdateStatus(id, ownerID uint, status string) error {
	room, err := s.roomRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}
	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this room")
	}

	return s.roomRepo.UpdateStatus(id, status)
}

// Delete soft deletes a room
func (s *RoomService) Delete(id, ownerID uint) error {
	room, err := s.roomRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}
	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this room")
	}

	return s.roomRepo.Delete(id)
}

// GetByID gets a room by ID
func (s *RoomService) GetByID(id, ownerID uint) (*entities.Room, error) {
	room, err := s.roomRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	// Verify ownership
	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return nil, err
	}
	if building.OwnerID != ownerID {
		return nil, errors.New("forbidden: not the owner of this room")
	}

	return room, nil
}

// ListByBuilding returns paginated rooms for a building
func (s *RoomService) ListByBuilding(buildingID, ownerID uint, page, limit int) ([]*entities.Room, int64, error) {
	// Verify building ownership
	building, err := s.buildingRepo.FindByID(buildingID)
	if err != nil {
		return nil, 0, err
	}
	if building.OwnerID != ownerID {
		return nil, 0, errors.New("forbidden: not the owner of this building")
	}

	offset := (page - 1) * limit
	return s.roomRepo.ListByBuilding(buildingID, limit, offset)
}
