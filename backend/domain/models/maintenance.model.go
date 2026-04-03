package models

import "time"

type CreateMaintenanceRequest struct {
	RoomID      uint     `json:"room_id" validate:"required"`
	Title       string   `json:"title" validate:"required"`
	Description string   `json:"description"`
	Priority    string   `json:"priority"`
	Images      []string `json:"images"`
}

type UpdateMaintenanceRequest struct {
	Status      string     `json:"status"`
	ResolvedAt  *time.Time `json:"resolved_at"`
}

type MaintenanceResponse struct {
	ID          uint       `json:"id"`
	RoomID      uint       `json:"room_id"`
	RoomNumber  string     `json:"room_number"`
	TenantID    uint       `json:"tenant_id"`
	TenantName  string     `json:"tenant_name"`
	Title       string     `json:"title"`
	Description string     `json:"description"`
	Images      []string   `json:"images"`
	Status      string     `json:"status"`
	Priority    string     `json:"priority"`
	ResolvedAt  *time.Time `json:"resolved_at"`
	CreatedAt   time.Time  `json:"created_at"`
}
