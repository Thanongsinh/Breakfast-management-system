package entities

import "time"

type Bill struct {
	ID             uint      `gorm:"primaryKey"`
	TenantID       uint      `gorm:"not null;index"`
	RoomID         uint      `gorm:"not null;index"`
	Month          int       `gorm:"not null"`
	Year           int       `gorm:"not null"`
	RentAmount     float64   `gorm:"not null"`
	WaterUnit      float64
	WaterPrice     float64
	ElectricUnit   float64
	ElectricPrice  float64
	OtherFees      float64
	OtherFeesNote  string
	Total          float64   `gorm:"not null"`
	DueDate        time.Time `gorm:"not null"`
	Status         string    `gorm:"not null"` // unpaid | paid | overdue
	CreatedAt      time.Time
	UpdatedAt      time.Time
}
