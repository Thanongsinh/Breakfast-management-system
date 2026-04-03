package entities

import (
	"github.com/lib/pq"
	"time"
)

type MaintenanceRequest struct {
	ID          uint   `gorm:"primaryKey"`
	RoomID      uint   `gorm:"not null;index"`
	TenantID    uint   `gorm:"not null;index"`
	Title       string `gorm:"not null"`
	Description string
	Images      pq.StringArray `gorm:"type:text[]"`
	Status      string         `gorm:"not null"` // pending | in_progress | done
	Priority    string         // low | medium | high
	ResolvedAt  *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
