package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type ContractRepository struct {
	DB *gorm.DB
}

func NewContractRepository(db *gorm.DB) *ContractRepository {
	return &ContractRepository{DB: db}
}

// Create creates a new contract
func (r *ContractRepository) Create(contract *entities.Contract) error {
	return r.DB.Create(contract).Error
}

// FindByID finds a contract by ID with preloaded relationships
func (r *ContractRepository) FindByID(id uint) (*entities.Contract, error) {
	var contract entities.Contract
	err := r.DB.Preload("Room").Preload("Tenant").First(&contract, id).Error
	if err != nil {
		return nil, err
	}
	return &contract, nil
}

// FindActiveByTenant finds active contract for a tenant
func (r *ContractRepository) FindActiveByTenant(tenantID uint) (*entities.Contract, error) {
	var contract entities.Contract
	err := r.DB.Where("tenant_id = ? AND status = ?", tenantID, "active").
		Preload("Room").Preload("Tenant").
		First(&contract).Error
	if err != nil {
		return nil, err
	}
	return &contract, nil
}

// Update updates a contract
func (r *ContractRepository) Update(contract *entities.Contract) error {
	return r.DB.Save(contract).Error
}

// List returns paginated list of contracts for an owner
func (r *ContractRepository) List(ownerID uint, page, limit int) ([]entities.Contract, int64, error) {
	var contracts []entities.Contract
	var total int64

	offset := (page - 1) * limit

	// Count total
	query := r.DB.Model(&entities.Contract{}).
		Joins("JOIN rooms ON rooms.id = contracts.room_id").
		Joins("JOIN buildings ON buildings.id = rooms.building_id").
		Where("buildings.owner_id = ?", ownerID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := query.
		Preload("Room").Preload("Tenant").
		Offset(offset).Limit(limit).
		Find(&contracts).Error

	if err != nil {
		return nil, 0, err
	}

	return contracts, total, nil
}

// FindAllActive finds all active contracts
func (r *ContractRepository) FindAllActive() ([]entities.Contract, error) {
	var contracts []entities.Contract
	err := r.DB.Where("status = ?", "active").
		Preload("Room").Preload("Tenant").
		Find(&contracts).Error
	if err != nil {
		return nil, err
	}
	return contracts, nil
}
