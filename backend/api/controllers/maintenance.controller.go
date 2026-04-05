package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// MaintenanceController handles maintenance request-related requests
type MaintenanceController struct {
	maintenanceService *services.MaintenanceService
}

// NewMaintenanceController creates a new instance of MaintenanceController
func NewMaintenanceController(maintenanceService *services.MaintenanceService) *MaintenanceController {
	return &MaintenanceController{
		maintenanceService: maintenanceService,
	}
}

// Create handles maintenance request creation (by tenant)
func (ctrl *MaintenanceController) Create(c *fiber.Ctx) error {
	// Extract tenantID from JWT claims (set by AuthMiddleware)
	tenantID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateMaintenanceRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.RoomID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room ID is required")
	}
	if req.Title == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Title is required")
	}

	// Call service
	maintenance, err := ctrl.maintenanceService.Create(tenantID, req)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.MaintenanceResponse{
		ID:          maintenance.ID,
		RoomID:      maintenance.RoomID,
		TenantID:    maintenance.TenantID,
		Title:       maintenance.Title,
		Description: maintenance.Description,
		Images:      maintenance.Images,
		Status:      maintenance.Status,
		Priority:    maintenance.Priority,
		ResolvedAt:  maintenance.ResolvedAt,
		CreatedAt:   maintenance.CreatedAt,
	})
}

// GetByID retrieves a maintenance request by ID
func (ctrl *MaintenanceController) GetByID(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Get role for authorization checks
	role, _ := c.Locals("role").(string)

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid maintenance request ID")
	}

	// Call service
	maintenance, err := ctrl.maintenanceService.GetByID(uint(id))
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Maintenance request not found")
	}

	// Authorization: tenants can only see their own requests
	if role == "tenant" && maintenance.TenantID != userID {
		return utilities.ErrorResponse(c, fiber.StatusForbidden, "forbidden: not your maintenance request")
	}

	// Build response
	return utilities.SuccessResponse(c, models.MaintenanceResponse{
		ID:          maintenance.ID,
		RoomID:      maintenance.RoomID,
		TenantID:    maintenance.TenantID,
		Title:       maintenance.Title,
		Description: maintenance.Description,
		Images:      maintenance.Images,
		Status:      maintenance.Status,
		Priority:    maintenance.Priority,
		ResolvedAt:  maintenance.ResolvedAt,
		CreatedAt:   maintenance.CreatedAt,
	})
}

// Update handles maintenance request update (by owner)
func (ctrl *MaintenanceController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid maintenance request ID")
	}

	// Parse request body
	var req models.UpdateMaintenanceRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Call service
	err = ctrl.maintenanceService.Update(uint(id), ownerID, req)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Maintenance request updated successfully",
	})
}

// List retrieves maintenance requests with pagination
func (ctrl *MaintenanceController) List(c *fiber.Ctx) error {
	// Extract userID and role from JWT claims
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	role, _ := c.Locals("role").(string)

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	var maintenanceRequests []models.MaintenanceResponse
	var total int64
	var err error

	// Different list logic based on role
	if role == "tenant" {
		// Tenant sees only their own requests
		var requests []entities.MaintenanceRequest
		requests, total, err = ctrl.maintenanceService.ListByTenant(userID, page, limit)
		if err != nil {
			return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
		}

		// Build response list
		maintenanceRequests = make([]models.MaintenanceResponse, len(requests))
		for i, req := range requests {
			maintenanceRequests[i] = models.MaintenanceResponse{
				ID:          req.ID,
				RoomID:      req.RoomID,
				TenantID:    req.TenantID,
				Title:       req.Title,
				Description: req.Description,
				Images:      req.Images,
				Status:      req.Status,
				Priority:    req.Priority,
				ResolvedAt:  req.ResolvedAt,
				CreatedAt:   req.CreatedAt,
			}
		}
	} else if role == "owner" || role == "admin" {
		// Owner sees requests for their buildings
		status := c.Query("status", "")
		var requests []entities.MaintenanceRequest
		requests, total, err = ctrl.maintenanceService.ListByOwner(userID, status, page, limit)
		if err != nil {
			return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
		}

		// Build response list
		maintenanceRequests = make([]models.MaintenanceResponse, len(requests))
		for i, req := range requests {
			maintenanceRequests[i] = models.MaintenanceResponse{
				ID:          req.ID,
				RoomID:      req.RoomID,
				TenantID:    req.TenantID,
				Title:       req.Title,
				Description: req.Description,
				Images:      req.Images,
				Status:      req.Status,
				Priority:    req.Priority,
				ResolvedAt:  req.ResolvedAt,
				CreatedAt:   req.CreatedAt,
			}
		}
	} else {
		return utilities.ErrorResponse(c, fiber.StatusForbidden, "Invalid role")
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, maintenanceRequests, pagination)
}

// UploadImages handles maintenance request image uploads
func (ctrl *MaintenanceController) UploadImages(c *fiber.Ctx) error {
	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid maintenance request ID")
	}

	// Parse multipart form
	form, err := c.MultipartForm()
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid multipart form")
	}

	// Get files from "images" field
	files := form.File["images"]
	if len(files) == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "No images provided")
	}

	// Call service to upload images
	err = ctrl.maintenanceService.UploadImages(uint(id), files)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Images uploaded successfully",
	})
}
