package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type BuildingRepository struct {
	DB *gorm.DB
}

func NewBuildingRepository(db *gorm.DB) *BuildingRepository {
	return &BuildingRepository{DB: db}
}

func (r *BuildingRepository) Create(building *entities.Building) error {
	return r.DB.Create(building).Error
}

func (r *BuildingRepository) FindByID(id uint) (*entities.Building, error) {
	var building entities.Building
	err := r.DB.First(&building, id).Error
	return &building, err
}

func (r *BuildingRepository) Update(building *entities.Building) error {
	return r.DB.Save(building).Error
}

func (r *BuildingRepository) Delete(id uint) error {
	return r.DB.Delete(&entities.Building{}, id).Error
}

func (r *BuildingRepository) ListByOwner(ownerID uint, limit, offset int) ([]*entities.Building, int64, error) {
	var buildings []*entities.Building
	var total int64
	query := r.DB.Where("owner_id = ?", ownerID)
	query.Model(&entities.Building{}).Count(&total)
	err := query.Offset(offset).Limit(limit).Find(&buildings).Error
	return buildings, total, err
}

func (r *BuildingRepository) List(limit, offset int) ([]*entities.Building, int64, error) {
	var buildings []*entities.Building
	var total int64
	r.DB.Model(&entities.Building{}).Count(&total)
	err := r.DB.Offset(offset).Limit(limit).Find(&buildings).Error
	return buildings, total, err
}
