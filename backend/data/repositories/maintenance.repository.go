package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type MaintenanceRepository struct {
	DB *gorm.DB
}

func NewMaintenanceRepository(db *gorm.DB) *MaintenanceRepository {
	return &MaintenanceRepository{DB: db}
}

// Create creates a new maintenance request
func (r *MaintenanceRepository) Create(req *entities.MaintenanceRequest) error {
	return r.DB.Create(req).Error
}

// FindByID finds a maintenance request by ID with preloaded relationships
func (r *MaintenanceRepository) FindByID(id uint) (*entities.MaintenanceRequest, error) {
	var req entities.MaintenanceRequest
	err := r.DB.Preload("Room").Preload("Tenant").First(&req, id).Error
	if err != nil {
		return nil, err
	}
	return &req, nil
}

// Update updates a maintenance request
func (r *MaintenanceRepository) Update(req *entities.MaintenanceRequest) error {
	return r.DB.Save(req).Error
}

// ListByTenant returns paginated list of maintenance requests for a tenant
func (r *MaintenanceRepository) ListByTenant(tenantID uint, page, limit int) ([]entities.MaintenanceRequest, int64, error) {
	var requests []entities.MaintenanceRequest
	var total int64

	offset := (page - 1) * limit

	// Count total
	if err := r.DB.Model(&entities.MaintenanceRequest{}).Where("tenant_id = ?", tenantID).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := r.DB.Where("tenant_id = ?", tenantID).
		Preload("Room").
		Order("created_at DESC").
		Offset(offset).Limit(limit).
		Find(&requests).Error

	if err != nil {
		return nil, 0, err
	}

	return requests, total, nil
}

// ListByOwner returns paginated list of maintenance requests for an owner with status filter
func (r *MaintenanceRepository) ListByOwner(ownerID uint, status string, page, limit int) ([]entities.MaintenanceRequest, int64, error) {
	var requests []entities.MaintenanceRequest
	var total int64

	offset := (page - 1) * limit

	// Build query with joins
	query := r.DB.Model(&entities.MaintenanceRequest{}).
		Joins("JOIN rooms ON rooms.id = maintenance_requests.room_id").
		Joins("JOIN buildings ON buildings.id = rooms.building_id").
		Where("buildings.owner_id = ?", ownerID)

	// Apply status filter if provided
	if status != "" {
		query = query.Where("maintenance_requests.status = ?", status)
	}

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := query.
		Preload("Room").Preload("Tenant").
		Order("maintenance_requests.created_at DESC").
		Offset(offset).Limit(limit).
		Find(&requests).Error

	if err != nil {
		return nil, 0, err
	}

	return requests, total, nil
}
