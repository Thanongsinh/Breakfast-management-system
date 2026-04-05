package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/models"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// BuildingController handles building-related requests
type BuildingController struct {
	buildingService *services.BuildingService
}

// NewBuildingController creates a new instance of BuildingController
func NewBuildingController(buildingService *services.BuildingService) *BuildingController {
	return &BuildingController{
		buildingService: buildingService,
	}
}

// Create handles building creation
func (ctrl *BuildingController) Create(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateBuildingRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.Name == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Building name is required")
	}

	// Call service
	building, err := ctrl.buildingService.Create(ownerID, req)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.BuildingResponse{
		ID:          building.ID,
		OwnerID:     building.OwnerID,
		Name:        building.Name,
		Address:     building.Address,
		TotalFloors: building.TotalFloors,
		Images:      building.Images,
	})
}

// GetByID retrieves a building by ID
func (ctrl *BuildingController) GetByID(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid building ID")
	}

	// Call service
	building, err := ctrl.buildingService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Building not found")
	}

	// Build response
	return utilities.SuccessResponse(c, models.BuildingResponse{
		ID:          building.ID,
		OwnerID:     building.OwnerID,
		Name:        building.Name,
		Address:     building.Address,
		TotalFloors: building.TotalFloors,
		Images:      building.Images,
	})
}

// Update handles building update
func (ctrl *BuildingController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid building ID")
	}

	// Parse request body
	var req models.UpdateBuildingRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Call service
	err = ctrl.buildingService.Update(uint(id), ownerID, req)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Building updated successfully",
	})
}

// Delete handles building deletion
func (ctrl *BuildingController) Delete(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid building ID")
	}

	// Call service
	err = ctrl.buildingService.Delete(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Building deleted successfully",
	})
}

// List retrieves all buildings for the current owner
func (ctrl *BuildingController) List(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Call service
	buildings, total, err := ctrl.buildingService.List(ownerID, page, limit)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	buildingResponses := make([]models.BuildingResponse, len(buildings))
	for i, building := range buildings {
		buildingResponses[i] = models.BuildingResponse{
			ID:          building.ID,
			OwnerID:     building.OwnerID,
			Name:        building.Name,
			Address:     building.Address,
			TotalFloors: building.TotalFloors,
			Images:      building.Images,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, buildingResponses, pagination)
}
