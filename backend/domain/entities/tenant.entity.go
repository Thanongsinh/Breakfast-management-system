package entities

import "time"

type Tenant struct {
	ID               uint   `gorm:"primaryKey"`
	UserID           uint   `gorm:"not null;index"`
	RoomID           uint   `gorm:"not null;index"`
	ContractID       uint
	EmergencyContact string
	IDCardNumber     string
	MoveInDate       time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
	DeletedAt        *time.Time `gorm:"index"`
}
