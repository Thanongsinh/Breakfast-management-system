package entities

import (
	"github.com/lib/pq"
	"time"
)

type Room struct {
	ID         uint    `gorm:"primaryKey"`
	BuildingID uint    `gorm:"not null;index"`
	Number     string  `gorm:"not null"`
	Floor      int
	Type       string  // single | double | studio
	SizeSqm    float64
	RentPrice  float64 `gorm:"not null"`
	Status     string  `gorm:"not null"` // available | occupied | maintenance
	Images     pq.StringArray `gorm:"type:text[]"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
	DeletedAt  *time.Time `gorm:"index"`
}
