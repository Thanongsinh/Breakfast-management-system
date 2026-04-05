package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
)

// NotificationController handles notification-related requests
type NotificationController struct {
	notificationService *services.NotificationService
}

// NewNotificationController creates a new instance of NotificationController
func NewNotificationController(notificationService *services.NotificationService) *NotificationController {
	return &NotificationController{
		notificationService: notificationService,
	}
}

// SendBillReminder sends a bill reminder notification to a tenant
func (ctrl *NotificationController) SendBillReminder(c *fiber.Ctx) error {
	// Extract userID from JWT claims (set by AuthMiddleware)
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req struct {
		TenantName string  `json:"tenant_name"`
		BillAmount float64 `json:"bill_amount"`
		DueDate    string  `json:"due_date"`
	}
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.TenantName == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Tenant name is required")
	}
	if req.BillAmount <= 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Bill amount must be greater than zero")
	}
	if req.DueDate == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Due date is required")
	}

	// Call service
	err := ctrl.notificationService.SendBillReminder(req.TenantName, req.BillAmount, req.DueDate)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, fiber.Map{
		"message":  "Bill reminder sent successfully",
		"user_id":  userID,
		"sent_to":  req.TenantName,
		"amount":   req.BillAmount,
		"due_date": req.DueDate,
	})
}

// SendPaymentConfirmation sends a payment confirmation notification to a tenant
func (ctrl *NotificationController) SendPaymentConfirmation(c *fiber.Ctx) error {
	// Extract userID from JWT claims (set by AuthMiddleware)
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse request body
	var req struct {
		TenantName  string  `json:"tenant_name"`
		Amount      float64 `json:"amount"`
		ReceiptPath string  `json:"receipt_path"`
	}
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.TenantName == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Tenant name is required")
	}
	if req.Amount <= 0 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Amount must be greater than zero")
	}
	if req.ReceiptPath == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Receipt path is required")
	}

	// Call service
	err := ctrl.notificationService.SendPaymentConfirmation(req.TenantName, req.Amount, req.ReceiptPath)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	// Build response
	return utilities.SuccessResponse(c, fiber.Map{
		"message":      "Payment confirmation sent successfully",
		"user_id":      userID,
		"sent_to":      req.TenantName,
		"amount":       req.Amount,
		"receipt_path": req.ReceiptPath,
	})
}
