package entities

import (
	"github.com/lib/pq"
	"time"
)

type Building struct {
	ID          uint `gorm:"primaryKey"`
	OwnerID     uint `gorm:"not null;index"`
	Name        string `gorm:"not null"`
	Address     string
	TotalFloors int
	Images      pq.StringArray `gorm:"type:text[]"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
