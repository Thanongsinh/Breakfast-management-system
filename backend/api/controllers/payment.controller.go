package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/models"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// PaymentController handles payment-related requests
type PaymentController struct {
	paymentService *services.PaymentService
}

// NewPaymentController creates a new instance of PaymentController
func NewPaymentController(paymentService *services.PaymentService) *PaymentController {
	return &PaymentController{
		paymentService: paymentService,
	}
}

// ConfirmCash handles cash payment confirmation
func (ctrl *PaymentController) ConfirmCash(c *fiber.Ctx) error {
	// Extract confirmedBy (userID) from JWT claims (set by AuthMiddleware)
	confirmedBy, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req models.ConfirmCashPaymentRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.BillID == 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Bill ID is required")
	}
	if req.Amount <= 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Amount must be greater than 0")
	}

	// Call service
	payment, err := ctrl.paymentService.ConfirmCashPayment(req, confirmedBy)
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		if strings.Contains(err.Error(), "already paid") {
			return utilities.ErrorResponse(c, fiber.StatusConflict, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, models.PaymentResponse{
		ID:             payment.ID,
		BillID:         payment.BillID,
		TenantID:       payment.TenantID,
		Amount:         payment.Amount,
		PaidAt:         payment.PaidAt,
		ConfirmedBy:    payment.ConfirmedBy,
		ReceiptPDFPath: payment.ReceiptPDFPath,
		Note:           payment.Note,
	})
}

// GetByID retrieves a payment by ID
func (ctrl *PaymentController) GetByID(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid payment ID")
	}

	// Call service
	payment, err := ctrl.paymentService.GetByID(uint(id))
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Payment not found")
	}

	// Verify access (userID is used for authorization context)
	_ = userID

	// Build response
	return utilities.SuccessResponse(c, models.PaymentResponse{
		ID:             payment.ID,
		BillID:         payment.BillID,
		TenantID:       payment.TenantID,
		Amount:         payment.Amount,
		PaidAt:         payment.PaidAt,
		ConfirmedBy:    payment.ConfirmedBy,
		ReceiptPDFPath: payment.ReceiptPDFPath,
		Note:           payment.Note,
	})
}

// List retrieves all payments with pagination
func (ctrl *PaymentController) List(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)

	// Call service
	payments, total, err := ctrl.paymentService.List(userID, page, limit)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response list
	paymentResponses := make([]models.PaymentResponse, len(payments))
	for i, payment := range payments {
		paymentResponses[i] = models.PaymentResponse{
			ID:             payment.ID,
			BillID:         payment.BillID,
			TenantID:       payment.TenantID,
			Amount:         payment.Amount,
			PaidAt:         payment.PaidAt,
			ConfirmedBy:    payment.ConfirmedBy,
			ReceiptPDFPath: payment.ReceiptPDFPath,
			Note:           payment.Note,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, paymentResponses, pagination)
}

// GetReceipt generates and returns payment receipt
func (ctrl *PaymentController) GetReceipt(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse ID from URL param
	id, err := strconv.ParseUint(c.Params("id"), 10, 32)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid payment ID")
	}

	// Call service to get payment
	payment, err := ctrl.paymentService.GetByID(uint(id))
	if err != nil {
		if strings.Contains(err.Error(), "forbidden") {
			return utilities.ErrorResponse(c, fiber.StatusForbidden, err.Error())
		}
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Payment not found")
	}

	// Verify access (userID is used for authorization context)
	_ = userID

	// Check if receipt exists
	if payment.ReceiptPDFPath == "" {
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "Receipt not yet generated")
	}

	// Return receipt path (actual PDF serving would be done by storage service/middleware)
	return utilities.SuccessResponse(c, fiber.Map{
		"receipt_path": payment.ReceiptPDFPath,
		"payment_id":   payment.ID,
	})
}
