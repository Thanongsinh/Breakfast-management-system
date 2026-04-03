package entities

import "time"

type Contract struct {
	ID         uint      `gorm:"primaryKey"`
	RoomID     uint      `gorm:"not null;index"`
	TenantID   uint      `gorm:"not null;index"`
	StartDate  time.Time `gorm:"not null"`
	EndDate    time.Time `gorm:"not null"`
	RentAmount float64   `gorm:"not null"`
	Deposit    float64
	PDFPath    string
	Status     string    `gorm:"not null"` // active | expired | terminated
	CreatedAt  time.Time
	UpdatedAt  time.Time
	DeletedAt  *time.Time `gorm:"index"`
}
