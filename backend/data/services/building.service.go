package services

import (
	"errors"
	"github.com/lib/pq"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
)

type BuildingService struct {
	buildingRepo *repositories.BuildingRepository
}

func NewBuildingService(buildingRepo *repositories.BuildingRepository) *BuildingService {
	return &BuildingService{
		buildingRepo: buildingRepo,
	}
}

// Create creates a new building
func (s *BuildingService) Create(ownerID uint, req models.CreateBuildingRequest) (*entities.Building, error) {
	building := &entities.Building{
		OwnerID:     ownerID,
		Name:        req.Name,
		Address:     req.Address,
		TotalFloors: req.TotalFloors,
		Images:      pq.StringArray(req.Images),
	}

	if err := s.buildingRepo.Create(building); err != nil {
		return nil, err
	}

	return building, nil
}

// Update updates a building (with ownership verification)
func (s *BuildingService) Update(id, ownerID uint, req models.UpdateBuildingRequest) error {
	building, err := s.buildingRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this building")
	}

	// Update fields
	if req.Name != "" {
		building.Name = req.Name
	}
	if req.Address != "" {
		building.Address = req.Address
	}
	if req.TotalFloors > 0 {
		building.TotalFloors = req.TotalFloors
	}
	if len(req.Images) > 0 {
		building.Images = pq.StringArray(req.Images)
	}

	return s.buildingRepo.Update(building)
}

// Delete soft deletes a building (with ownership verification)
func (s *BuildingService) Delete(id, ownerID uint) error {
	building, err := s.buildingRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this building")
	}

	return s.buildingRepo.Delete(id)
}

// GetByID gets a building by ID (with ownership verification)
func (s *BuildingService) GetByID(id, ownerID uint) (*entities.Building, error) {
	building, err := s.buildingRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	// Verify ownership
	if building.OwnerID != ownerID {
		return nil, errors.New("forbidden: not the owner of this building")
	}

	return building, nil
}

// List returns paginated buildings for an owner
func (s *BuildingService) List(ownerID uint, page, limit int) ([]*entities.Building, int64, error) {
	offset := (page - 1) * limit
	return s.buildingRepo.ListByOwner(ownerID, limit, offset)
}
