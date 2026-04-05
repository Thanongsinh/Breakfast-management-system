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

// TenantController handles tenant-related requests
type TenantController struct {
	tenantService *services.TenantService
}

// NewTenantController creates a new instance of TenantController
func NewTenantController(tenantService *services.TenantService) *TenantController {
	return &TenantController{
		tenantService: tenantService,
	}
}

// Create handles tenant creation
func (ctrl *TenantController) Create(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateTenantRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.UserID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "User ID is required")
	}
	if req.RoomID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room ID is required")
	}

	// Build entity from request
	tenant := &entities.Tenant{
		UserID:           req.UserID,
		RoomID:           req.RoomID,
		ContractID:       req.ContractID,
		EmergencyContact: req.EmergencyContact,
		IDCardNumber:     req.IDCardNumber,
		MoveInDate:       req.MoveInDate,
	}

	// Call service
	err := ctrl.tenantService.Create(ownerID, tenant)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		if strings.Contains(err.Error(), "already occupied") {
			return utilities.ErrorResponse(c, fiber.StatusConflict, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.TenantResponse{
		ID:               tenant.ID,
		UserID:           tenant.UserID,
		RoomID:           tenant.RoomID,
		ContractID:       tenant.ContractID,
		EmergencyContact: tenant.EmergencyContact,
		IDCardNumber:     tenant.IDCardNumber,
		MoveInDate:       tenant.MoveInDate,
	})
}

// GetByID retrieves a tenant by ID
func (ctrl *TenantController) GetByID(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid tenant ID")
	}

	// Call service
	tenant, err := ctrl.tenantService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Tenant not found")
	}

	// Build response
	return utilities.SuccessResponse(c, models.TenantResponse{
		ID:               tenant.ID,
		UserID:           tenant.UserID,
		RoomID:           tenant.RoomID,
		ContractID:       tenant.ContractID,
		EmergencyContact: tenant.EmergencyContact,
		IDCardNumber:     tenant.IDCardNumber,
		MoveInDate:       tenant.MoveInDate,
	})
}

// Update handles tenant update
func (ctrl *TenantController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid tenant ID")
	}

	// Parse request body
	var req models.UpdateTenantRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Build entity from request
	tenant := &entities.Tenant{
		EmergencyContact: req.EmergencyContact,
		IDCardNumber:     req.IDCardNumber,
		MoveInDate:       req.MoveInDate,
	}

	// Call service
	err = ctrl.tenantService.Update(uint(id), ownerID, tenant)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Tenant updated successfully",
	})
}

// Delete handles tenant deletion
func (ctrl *TenantController) Delete(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid tenant ID")
	}

	// Call service
	err = ctrl.tenantService.Delete(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Tenant deleted successfully",
	})
}

// List retrieves all tenants for the current owner
func (ctrl *TenantController) List(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Call service
	tenants, total, err := ctrl.tenantService.List(ownerID, page, limit)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	tenantResponses := make([]models.TenantResponse, len(tenants))
	for i, tenant := range tenants {
		tenantResponses[i] = models.TenantResponse{
			ID:               tenant.ID,
			UserID:           tenant.UserID,
			RoomID:           tenant.RoomID,
			ContractID:       tenant.ContractID,
			EmergencyContact: tenant.EmergencyContact,
			IDCardNumber:     tenant.IDCardNumber,
			MoveInDate:       tenant.MoveInDate,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, tenantResponses, pagination)
}
