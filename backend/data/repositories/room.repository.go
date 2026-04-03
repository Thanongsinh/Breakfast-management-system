package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type RoomRepository struct {
	DB *gorm.DB
}

func NewRoomRepository(db *gorm.DB) *RoomRepository {
	return &RoomRepository{DB: db}
}

func (r *RoomRepository) Create(room *entities.Room) error {
	return r.DB.Create(room).Error
}

func (r *RoomRepository) FindByID(id uint) (*entities.Room, error) {
	var room entities.Room
	err := r.DB.First(&room, id).Error
	return &room, err
}

func (r *RoomRepository) Update(room *entities.Room) error {
	return r.DB.Save(room).Error
}

func (r *RoomRepository) Delete(id uint) error {
	return r.DB.Delete(&entities.Room{}, id).Error
}

func (r *RoomRepository) ListByBuilding(buildingID uint, limit, offset int) ([]*entities.Room, int64, error) {
	var rooms []*entities.Room
	var total int64
	query := r.DB.Where("building_id = ? AND deleted_at IS NULL", buildingID)
	query.Model(&entities.Room{}).Count(&total)
	err := query.Offset(offset).Limit(limit).Find(&rooms).Error
	return rooms, total, err
}

func (r *RoomRepository) ListByStatus(status string, limit, offset int) ([]*entities.Room, int64, error) {
	var rooms []*entities.Room
	var total int64
	query := r.DB.Where("status = ? AND deleted_at IS NULL", status)
	query.Model(&entities.Room{}).Count(&total)
	err := query.Offset(offset).Limit(limit).Find(&rooms).Error
	return rooms, total, err
}

func (r *RoomRepository) UpdateStatus(id uint, status string) error {
	return r.DB.Model(&entities.Room{}).Where("id = ?", id).Update("status", status).Error
}

func (r *RoomRepository) FindByBuildingAndNumber(buildingID uint, number string) (*entities.Room, error) {
	var room entities.Room
	err := r.DB.Where("building_id = ? AND number = ? AND deleted_at IS NULL", buildingID, number).First(&room).Error
	return &room, err
}
