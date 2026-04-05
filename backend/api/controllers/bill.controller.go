package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/models"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// BillController handles bill-related requests
type BillController struct {
	billService *services.BillService
}

// NewBillController creates a new instance of BillController
func NewBillController(billService *services.BillService) *BillController {
	return &BillController{
		billService: billService,
	}
}

// Create handles bill creation
func (ctrl *BillController) Create(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.CreateBillRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.TenantID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Tenant ID is required")
	}
	if req.RoomID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Room ID is required")
	}
	if req.Month < 1 || req.Month > 12 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid month")
	}
	if req.Year < 2000 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid year")
	}

	// Call service
	err := ctrl.billService.CreateBill(req)
	if err != nil {
		if strings.Contains(err.Error(), "already exists") {
			return utilities.ErrorResponse(c, fiber.StatusConflict, err.Error())
		}
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Bill created successfully",
	})
}

// GetByID retrieves a bill by ID
func (ctrl *BillController) GetByID(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid bill ID")
	}

	// Call service
	bill, err := ctrl.billService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Bill not found")
	}

	// Build response
	return utilities.SuccessResponse(c, models.BillResponse{
		ID:            bill.ID,
		TenantID:      bill.TenantID,
		TenantName:    "", // Will be populated by repository join if needed
		RoomID:        bill.RoomID,
		RoomNumber:    "", // Will be populated by repository join if needed
		Month:         bill.Month,
		Year:          bill.Year,
		RentAmount:    bill.RentAmount,
		WaterUnit:     bill.WaterUnit,
		WaterPrice:    bill.WaterPrice,
		ElectricUnit:  bill.ElectricUnit,
		ElectricPrice: bill.ElectricPrice,
		OtherFees:     bill.OtherFees,
		OtherFeesNote: bill.OtherFeesNote,
		Total:         bill.Total,
		DueDate:       bill.DueDate,
		Status:        bill.Status,
	})
}

// Update handles bill update
func (ctrl *BillController) Update(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid bill ID")
	}

	// Parse request body
	var req struct {
		WaterUnit     float64 `json:"water_unit"`
		ElectricUnit  float64 `json:"electric_unit"`
		OtherFees     float64 `json:"other_fees"`
		OtherFeesNote string  `json:"other_fees_note"`
	}
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Verify ownership before update
	_, err = ctrl.billService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Bill not found")
	}

	// Call service
	err = ctrl.billService.UpdateBill(uint(id), req.WaterUnit, req.ElectricUnit, req.OtherFees, req.OtherFeesNote)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Bill updated successfully",
	})
}

// Delete handles bill deletion
func (ctrl *BillController) Delete(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid bill ID")
	}

	// Verify ownership before delete
	_, err = ctrl.billService.GetByID(uint(id), ownerID)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Bill not found")
	}

	// Note: BillService doesn't have a Delete method yet
	// This is a placeholder that would need to be implemented in the service layer
	return utilities.ErrorResponse(c, fiber.StatusNotImplemented, "Bill deletion not implemented")
}

// List retrieves all bills for the current owner
func (ctrl *BillController) List(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Parse filter params
	filters := make(map[string]interface{})
	if status := c.Query("status"); status != "" {
		filters["status"] = status
	}
	if month := c.QueryInt("month", 0); month > 0 {
		filters["month"] = month
	}
	if year := c.QueryInt("year", 0); year > 0 {
		filters["year"] = year
	}

	// Call service
	bills, total, err := ctrl.billService.List(ownerID, filters, page, limit)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	billResponses := make([]models.BillResponse, len(bills))
	for i, bill := range bills {
		billResponses[i] = models.BillResponse{
			ID:            bill.ID,
			TenantID:      bill.TenantID,
			TenantName:    "", // Will be populated by repository join if needed
			RoomID:        bill.RoomID,
			RoomNumber:    "", // Will be populated by repository join if needed
			Month:         bill.Month,
			Year:          bill.Year,
			RentAmount:    bill.RentAmount,
			WaterUnit:     bill.WaterUnit,
			WaterPrice:    bill.WaterPrice,
			ElectricUnit:  bill.ElectricUnit,
			ElectricPrice: bill.ElectricPrice,
			OtherFees:     bill.OtherFees,
			OtherFeesNote: bill.OtherFeesNote,
			Total:         bill.Total,
			DueDate:       bill.DueDate,
			Status:        bill.Status,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, billResponses, pagination)
}

// GenerateBills generates bills for all active contracts for a given month/year
func (ctrl *BillController) GenerateBills(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (for authorization)
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.GenerateBillsRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.Month < 1 || req.Month > 12 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid month")
	}
	if req.Year < 2000 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid year")
	}

	// Call service
	err := ctrl.billService.GenerateBills(req.Month, req.Year)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Bills generated successfully",
	})
}
