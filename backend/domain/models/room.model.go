package models

type CreateRoomRequest struct {
	BuildingID uint     `json:"building_id" validate:"required"`
	Number     string   `json:"number" validate:"required"`
	Floor      int      `json:"floor"`
	Type       string   `json:"type"`
	SizeSqm    float64  `json:"size_sqm"`
	RentPrice  float64  `json:"rent_price" validate:"required"`
	Status     string   `json:"status" validate:"required"`
	Images     []string `json:"images"`
}

type UpdateRoomRequest struct {
	Number    string   `json:"number"`
	Floor     int      `json:"floor"`
	Type      string   `json:"type"`
	SizeSqm   float64  `json:"size_sqm"`
	RentPrice float64  `json:"rent_price"`
	Images    []string `json:"images"`
}

type UpdateRoomStatusRequest struct {
	Status string `json:"status" validate:"required"`
}

type RoomResponse struct {
	ID          uint     `json:"id"`
	BuildingID  uint     `json:"building_id"`
	Number      string   `json:"number"`
	Floor       int      `json:"floor"`
	Type        string   `json:"type"`
	SizeSqm     float64  `json:"size_sqm"`
	RentPrice   float64  `json:"rent_price"`
	Status      string   `json:"status"`
	Images      []string `json:"images"`
	TenantName  string   `json:"tenant_name,omitempty"`
}
