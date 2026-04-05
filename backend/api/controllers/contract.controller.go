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

// ContractController handles contract-related requests
type ContractController struct {
	contractService *services.ContractService
}

// NewContractController creates a new instance of ContractController
func NewContractController(contractService *services.ContractService) *ContractController {
	return &ContractController{
		contractService: contractService,
	}
}

// Create handles contract creation
func (ctrl *ContractController) Create(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateContractRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.RoomID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room ID is required")
	}
	if req.TenantID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Tenant ID is required")
	}
	if req.RentAmount <= 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Rent amount must be greater than 0")
	}

	// Create entity from request
	contract := &entities.Contract{
		RoomID:     req.RoomID,
		TenantID:   req.TenantID,
		StartDate:  req.StartDate,
		EndDate:    req.EndDate,
		RentAmount: req.RentAmount,
		Deposit:    req.Deposit,
		Status:     req.Status,
	}

	// Call service
	err := ctrl.contractService.Create(ownerID, contract)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.ContractResponse{
		ID:         contract.ID,
		RoomID:     contract.RoomID,
		TenantID:   contract.TenantID,
		StartDate:  contract.StartDate,
		EndDate:    contract.EndDate,
		RentAmount: contract.RentAmount,
		Deposit:    contract.Deposit,
		PDFPath:    contract.PDFPath,
		Status:     contract.Status,
		CreatedAt:  contract.CreatedAt,
		UpdatedAt:  contract.UpdatedAt,
	})
}

// GetByID retrieves a contract by ID
func (ctrl *ContractController) GetByID(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid contract ID")
	}

	// Call service
	contract, err := ctrl.contractService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Contract not found")
	}

	// Build response
	return utilities.SuccessResponse(c, models.ContractResponse{
		ID:         contract.ID,
		RoomID:     contract.RoomID,
		TenantID:   contract.TenantID,
		StartDate:  contract.StartDate,
		EndDate:    contract.EndDate,
		RentAmount: contract.RentAmount,
		Deposit:    contract.Deposit,
		PDFPath:    contract.PDFPath,
		Status:     contract.Status,
		CreatedAt:  contract.CreatedAt,
		UpdatedAt:  contract.UpdatedAt,
	})
}

// Update handles contract update
func (ctrl *ContractController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid contract ID")
	}

	// Parse request body
	var req models.UpdateContractRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Create entity from request
	contract := &entities.Contract{
		StartDate:  req.StartDate,
		EndDate:    req.EndDate,
		RentAmount: req.RentAmount,
		Deposit:    req.Deposit,
		Status:     req.Status,
	}

	// Call service
	err = ctrl.contractService.Update(uint(id), ownerID, contract)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Contract updated successfully",
	})
}

// Delete handles contract deletion
func (ctrl *ContractController) Delete(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	_, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid contract ID")
	}

	// Note: Delete method not found in ContractService
	// For now, we'll return an error - this should be implemented in the service layer
	return utilities.ErrorResponse(c, fiber.StatusNotImplemented, "Delete operation not yet implemented")
}

// List retrieves all contracts for the current owner
func (ctrl *ContractController) List(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Call service
	contracts, total, err := ctrl.contractService.List(ownerID, page, limit)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	contractResponses := make([]models.ContractResponse, len(contracts))
	for i, contract := range contracts {
		contractResponses[i] = models.ContractResponse{
			ID:         contract.ID,
			RoomID:     contract.RoomID,
			TenantID:   contract.TenantID,
			StartDate:  contract.StartDate,
			EndDate:    contract.EndDate,
			RentAmount: contract.RentAmount,
			Deposit:    contract.Deposit,
			PDFPath:    contract.PDFPath,
			Status:     contract.Status,
			CreatedAt:  contract.CreatedAt,
			UpdatedAt:  contract.UpdatedAt,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, contractResponses, pagination)
}

// GetPDF generates and returns contract PDF
func (ctrl *ContractController) GetPDF(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid contract ID")
	}

	// Verify ownership first
	_, err = ctrl.contractService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Contract not found")
	}

	// Generate PDF
	pdfPath, err := ctrl.contractService.GenerateContractPDF(uint(id))
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"pdf_path": pdfPath,
	})
}
