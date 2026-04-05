package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/models"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// RoomController handles room-related requests
type RoomController struct {
	roomService *services.RoomService
}

// NewRoomController creates a new instance of RoomController
func NewRoomController(roomService *services.RoomService) *RoomController {
	return &RoomController{
		roomService: roomService,
	}
}

// Create handles room creation
func (ctrl *RoomController) Create(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateRoomRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.BuildingID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Building ID is required")
	}
	if req.Number == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room number is required")
	}
	if req.RentPrice == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Rent price is required")
	}
	if req.Status == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room status is required")
	}

	// Call service
	room, err := ctrl.roomService.Create(ownerID, req)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.RoomResponse{
		ID:         room.ID,
		BuildingID: room.BuildingID,
		Number:     room.Number,
		Floor:      room.Floor,
		Type:       room.Type,
		SizeSqm:    room.SizeSqm,
		RentPrice:  room.RentPrice,
		Status:     room.Status,
		Images:     room.Images,
	})
}

// GetByID retrieves a room by ID
func (ctrl *RoomController) GetByID(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid room ID")
	}

	// Call service
	room, err := ctrl.roomService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Room not found")
	}

	// Build response
	return utilities.SuccessResponse(c, models.RoomResponse{
		ID:         room.ID,
		BuildingID: room.BuildingID,
		Number:     room.Number,
		Floor:      room.Floor,
		Type:       room.Type,
		SizeSqm:    room.SizeSqm,
		RentPrice:  room.RentPrice,
		Status:     room.Status,
		Images:     room.Images,
	})
}

// Update handles room update
func (ctrl *RoomController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid room ID")
	}

	// Parse request body
	var req models.UpdateRoomRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Call service
	err = ctrl.roomService.Update(uint(id), ownerID, req)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Room updated successfully",
	})
}

// Delete handles room deletion
func (ctrl *RoomController) Delete(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid room ID")
	}

	// Call service
	err = ctrl.roomService.Delete(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Room deleted successfully",
	})
}

// ListByBuilding retrieves all rooms for a specific building
func (ctrl *RoomController) ListByBuilding(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse building ID from URL param
	buildingID, err := strconv.ParseUint(c.Params("building_id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid building ID")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Call service
	rooms, total, err := ctrl.roomService.ListByBuilding(uint(buildingID), ownerID, page, limit)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	roomResponses := make([]models.RoomResponse, len(rooms))
	for i, room := range rooms {
		roomResponses[i] = models.RoomResponse{
			ID:         room.ID,
			BuildingID: room.BuildingID,
			Number:     room.Number,
			Floor:      room.Floor,
			Type:       room.Type,
			SizeSqm:    room.SizeSqm,
			RentPrice:  room.RentPrice,
			Status:     room.Status,
			Images:     room.Images,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, roomResponses, pagination)
}

// UpdateStatus handles room status update
func (ctrl *RoomController) UpdateStatus(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid room ID")
	}

	// Parse request body
	var req models.UpdateRoomStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.Status == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room status is required")
	}

	// Call service
	err = ctrl.roomService.UpdateStatus(uint(id), ownerID, req.Status)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Room status updated successfully",
	})
}
