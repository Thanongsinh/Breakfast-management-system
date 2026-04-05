package models

import "time"

type CreateTenantRequest struct {
	UserID           uint      `json:"user_id" validate:"required"`
	RoomID           uint      `json:"room_id" validate:"required"`
	ContractID       uint      `json:"contract_id"`
	EmergencyContact string    `json:"emergency_contact"`
	IDCardNumber     string    `json:"id_card_number"`
	MoveInDate       time.Time `json:"move_in_date" validate:"required"`
}

type UpdateTenantRequest struct {
	EmergencyContact string    `json:"emergency_contact"`
	IDCardNumber     string    `json:"id_card_number"`
	MoveInDate       time.Time `json:"move_in_date"`
}

type TenantResponse struct {
	ID               uint      `json:"id"`
	UserID           uint      `json:"user_id"`
	RoomID           uint      `json:"room_id"`
	ContractID       uint      `json:"contract_id"`
	EmergencyContact string    `json:"emergency_contact"`
	IDCardNumber     string    `json:"id_card_number"`
	MoveInDate       time.Time `json:"move_in_date"`
	UserName         string    `json:"user_name,omitempty"`
	RoomNumber       string    `json:"room_number,omitempty"`
}
