package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type TenantRepository struct {
	DB *gorm.DB
}

func NewTenantRepository(db *gorm.DB) *TenantRepository {
	return &TenantRepository{DB: db}
}

func (r *TenantRepository) Create(tenant *entities.Tenant) error {
	return r.DB.Create(tenant).Error
}

func (r *TenantRepository) FindByID(id uint) (*entities.Tenant, error) {
	var tenant entities.Tenant
	err := r.DB.First(&tenant, id).Error
	return &tenant, err
}

func (r *TenantRepository) FindByUserID(userID uint) (*entities.Tenant, error) {
	var tenant entities.Tenant
	err := r.DB.Where("user_id = ? AND deleted_at IS NULL", userID).First(&tenant).Error
	return &tenant, err
}

func (r *TenantRepository) FindByRoomID(roomID uint) (*entities.Tenant, error) {
	var tenant entities.Tenant
	err := r.DB.Where("room_id = ? AND deleted_at IS NULL", roomID).First(&tenant).Error
	return &tenant, err
}

func (r *TenantRepository) Update(tenant *entities.Tenant) error {
	return r.DB.Save(tenant).Error
}

func (r *TenantRepository) Delete(id uint) error {
	return r.DB.Delete(&entities.Tenant{}, id).Error
}

func (r *TenantRepository) List(limit, offset int) ([]*entities.Tenant, int64, error) {
	var tenants []*entities.Tenant
	var total int64
	query := r.DB.Where("deleted_at IS NULL")
	query.Model(&entities.Tenant{}).Count(&total)
	err := query.Offset(offset).Limit(limit).Find(&tenants).Error
	return tenants, total, err
}

func (r *TenantRepository) ListByOwner(ownerID uint, limit, offset int) ([]*entities.Tenant, int64, error) {
	var tenants []*entities.Tenant
	var total int64
	query := r.DB.Joins("JOIN rooms ON tenants.room_id = rooms.id").
		Joins("JOIN buildings ON rooms.building_id = buildings.id").
		Where("buildings.owner_id = ? AND tenants.deleted_at IS NULL", ownerID)
	query.Model(&entities.Tenant{}).Count(&total)
	err := query.Offset(offset).Limit(limit).Find(&tenants).Error
	return tenants, total, err
}
