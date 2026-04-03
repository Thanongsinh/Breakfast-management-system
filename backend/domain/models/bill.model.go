package models

import "time"

type CreateBillRequest struct {
	TenantID      uint    `json:"tenant_id" validate:"required"`
	RoomID        uint    `json:"room_id" validate:"required"`
	Month         int     `json:"month" validate:"required"`
	Year          int     `json:"year" validate:"required"`
	WaterUnit     float64 `json:"water_unit"`
	ElectricUnit  float64 `json:"electric_unit"`
	OtherFees     float64 `json:"other_fees"`
	OtherFeesNote string  `json:"other_fees_note"`
}

type GenerateBillsRequest struct {
	Month int `json:"month" validate:"required"`
	Year  int `json:"year" validate:"required"`
}

type BillResponse struct {
	ID             uint      `json:"id"`
	TenantID       uint      `json:"tenant_id"`
	TenantName     string    `json:"tenant_name"`
	RoomID         uint      `json:"room_id"`
	RoomNumber     string    `json:"room_number"`
	Month          int       `json:"month"`
	Year           int       `json:"year"`
	RentAmount     float64   `json:"rent_amount"`
	WaterUnit      float64   `json:"water_unit"`
	WaterPrice     float64   `json:"water_price"`
	ElectricUnit   float64   `json:"electric_unit"`
	ElectricPrice  float64   `json:"electric_price"`
	OtherFees      float64   `json:"other_fees"`
	OtherFeesNote  string    `json:"other_fees_note"`
	Total          float64   `json:"total"`
	DueDate        time.Time `json:"due_date"`
	Status         string    `json:"status"`
}
