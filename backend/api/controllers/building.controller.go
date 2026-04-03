package controllers

import (
	"github.com/gofiber/fiber/v2"
)

// BuildingController handles building-related requests
type BuildingController struct {
	// TODO: add building service dependency
}

// NewBuildingController creates a new instance of BuildingController
func NewBuildingController() *BuildingController {
	return &BuildingController{}
}

// Create handles building creation
func (ctrl *BuildingController) Create(c *fiber.Ctx) error {
	// TODO: implement create building logic
	return c.JSON(fiber.Map{
		"message": "Create building endpoint",
	})
}

// GetByID retrieves a building by ID
func (ctrl *BuildingController) GetByID(c *fiber.Ctx) error {
	// TODO: implement get building by ID logic
	return c.JSON(fiber.Map{
		"message": "Get building by ID endpoint",
	})
}

// Update handles building update
func (ctrl *BuildingController) Update(c *fiber.Ctx) error {
	// TODO: implement update building logic
	return c.JSON(fiber.Map{
		"message": "Update building endpoint",
	})
}

// Delete handles building deletion
func (ctrl *BuildingController) Delete(c *fiber.Ctx) error {
	// TODO: implement delete building logic
	return c.JSON(fiber.Map{
		"message": "Delete building endpoint",
	})
}

// List retrieves all buildings for the current owner
func (ctrl *BuildingController) List(c *fiber.Ctx) error {
	// TODO: implement list buildings logic
	return c.JSON(fiber.Map{
		"message": "List buildings endpoint",
	})
}
