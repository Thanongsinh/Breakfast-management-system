package controllers

import (
	"github.com/gofiber/fiber/v2"
)

// RoomController handles room-related requests
type RoomController struct {
	// TODO: add room service dependency
}

// NewRoomController creates a new instance of RoomController
func NewRoomController() *RoomController {
	return &RoomController{}
}

// Create handles room creation
func (ctrl *RoomController) Create(c *fiber.Ctx) error {
	// TODO: implement create room logic
	return c.JSON(fiber.Map{
		"message": "Create room endpoint",
	})
}

// GetByID retrieves a room by ID
func (ctrl *RoomController) GetByID(c *fiber.Ctx) error {
	// TODO: implement get room by ID logic
	return c.JSON(fiber.Map{
		"message": "Get room by ID endpoint",
	})
}

// Update handles room update
func (ctrl *RoomController) Update(c *fiber.Ctx) error {
	// TODO: implement update room logic
	return c.JSON(fiber.Map{
		"message": "Update room endpoint",
	})
}

// Delete handles room deletion
func (ctrl *RoomController) Delete(c *fiber.Ctx) error {
	// TODO: implement delete room logic
	return c.JSON(fiber.Map{
		"message": "Delete room endpoint",
	})
}

// ListByBuilding retrieves all rooms for a specific building
func (ctrl *RoomController) ListByBuilding(c *fiber.Ctx) error {
	// TODO: implement list rooms by building logic
	return c.JSON(fiber.Map{
		"message": "List rooms by building endpoint",
	})
}

// UpdateStatus handles room status update
func (ctrl *RoomController) UpdateStatus(c *fiber.Ctx) error {
	// TODO: implement update room status logic
	return c.JSON(fiber.Map{
		"message": "Update room status endpoint",
	})
}
