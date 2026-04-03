package services

import (
	"errors"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
)

type TenantService struct {
	tenantRepo   *repositories.TenantRepository
	roomRepo     *repositories.RoomRepository
	buildingRepo *repositories.BuildingRepository
}

func NewTenantService(
	tenantRepo *repositories.TenantRepository,
	roomRepo *repositories.RoomRepository,
	buildingRepo *repositories.BuildingRepository,
) *TenantService {
	return &TenantService{
		tenantRepo:   tenantRepo,
		roomRepo:     roomRepo,
		buildingRepo: buildingRepo,
	}
}

// Create creates a new tenant
func (s *TenantService) Create(ownerID uint, tenant *entities.Tenant) error {
	// Verify room ownership
	room, err := s.roomRepo.FindByID(tenant.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this room")
	}

	// Check if room is already occupied
	existingTenant, _ := s.tenantRepo.FindByRoomID(tenant.RoomID)
	if existingTenant != nil && existingTenant.ID > 0 {
		return errors.New("room is already occupied")
	}

	return s.tenantRepo.Create(tenant)
}

// Update updates a tenant
func (s *TenantService) Update(id, ownerID uint, tenant *entities.Tenant) error {
	existing, err := s.tenantRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	room, err := s.roomRepo.FindByID(existing.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this tenant")
	}

	// Update fields
	tenant.ID = id
	return s.tenantRepo.Update(tenant)
}

// Delete soft deletes a tenant
func (s *TenantService) Delete(id, ownerID uint) error {
	tenant, err := s.tenantRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	room, err := s.roomRepo.FindByID(tenant.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this tenant")
	}

	return s.tenantRepo.Delete(id)
}

// GetByID gets a tenant by ID
func (s *TenantService) GetByID(id, ownerID uint) (*entities.Tenant, error) {
	tenant, err := s.tenantRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	// Verify ownership
	room, err := s.roomRepo.FindByID(tenant.RoomID)
	if err != nil {
		return nil, err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return nil, err
	}

	if building.OwnerID != ownerID {
		return nil, errors.New("forbidden: not the owner of this tenant")
	}

	return tenant, nil
}

// List returns paginated tenants for an owner
func (s *TenantService) List(ownerID uint, page, limit int) ([]*entities.Tenant, int64, error) {
	offset := (page - 1) * limit
	return s.tenantRepo.ListByOwner(ownerID, limit, offset)
}

// GetByUserID gets tenant by user ID
func (s *TenantService) GetByUserID(userID uint) (*entities.Tenant, error) {
	return s.tenantRepo.FindByUserID(userID)
}
