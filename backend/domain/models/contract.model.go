package models

import "time"

type CreateContractRequest struct {
	RoomID     uint      `json:"room_id" validate:"required"`
	TenantID   uint      `json:"tenant_id" validate:"required"`
	StartDate  time.Time `json:"start_date" validate:"required"`
	EndDate    time.Time `json:"end_date" validate:"required"`
	RentAmount float64   `json:"rent_amount" validate:"required"`
	Deposit    float64   `json:"deposit"`
	Status     string    `json:"status"`
}

type UpdateContractRequest struct {
	StartDate  time.Time `json:"start_date"`
	EndDate    time.Time `json:"end_date"`
	RentAmount float64   `json:"rent_amount"`
	Deposit    float64   `json:"deposit"`
	Status     string    `json:"status"`
}

type ContractResponse struct {
	ID         uint      `json:"id"`
	RoomID     uint      `json:"room_id"`
	TenantID   uint      `json:"tenant_id"`
	StartDate  time.Time `json:"start_date"`
	EndDate    time.Time `json:"end_date"`
	RentAmount float64   `json:"rent_amount"`
	Deposit    float64   `json:"deposit"`
	PDFPath    string    `json:"pdf_path,omitempty"`
	Status     string    `json:"status"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}
