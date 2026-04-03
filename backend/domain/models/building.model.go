package models

type CreateBuildingRequest struct {
	Name        string   `json:"name" validate:"required"`
	Address     string   `json:"address"`
	TotalFloors int      `json:"total_floors"`
	Images      []string `json:"images"`
}

type UpdateBuildingRequest struct {
	Name        string   `json:"name"`
	Address     string   `json:"address"`
	TotalFloors int      `json:"total_floors"`
	Images      []string `json:"images"`
}

type BuildingResponse struct {
	ID          uint     `json:"id"`
	OwnerID     uint     `json:"owner_id"`
	Name        string   `json:"name"`
	Address     string   `json:"address"`
	TotalFloors int      `json:"total_floors"`
	Images      []string `json:"images"`
	RoomCount   int      `json:"room_count,omitempty"`
}
