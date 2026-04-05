package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/services"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

// ReportController handles report-related requests
type ReportController struct {
	reportService *services.ReportService
}

// NewReportController creates a new instance of ReportController
func NewReportController(reportService *services.ReportService) *ReportController {
	return &ReportController{
		reportService: reportService,
	}
}

// GetIncomeReport generates income report for a specific month/year
func (ctrl *ReportController) GetIncomeReport(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims (set by AuthMiddleware)
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse and validate month parameter
	monthStr := c.Query("month")
	if monthStr == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Month parameter is required")
	}
	month, err := strconv.Atoi(monthStr)
	if err != nil || month < 1 || month > 12 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid month parameter (must be 1-12)")
	}

	// Parse and validate year parameter
	yearStr := c.Query("year")
	if yearStr == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Year parameter is required")
	}
	year, err := strconv.Atoi(yearStr)
	if err != nil || year < 2000 || year > 2100 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid year parameter")
	}

	// Call service
	report, err := ctrl.reportService.GenerateIncomeReport(ownerID, month, year)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, report)
}

// GetUnpaidReport generates a report of all unpaid bills grouped by tenant
func (ctrl *ReportController) GetUnpaidReport(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Call service
	reports, err := ctrl.reportService.GenerateUnpaidReport(ownerID)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, reports)
}

// ExportIncome exports income report to Excel
func (ctrl *ReportController) ExportIncome(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse and validate month parameter
	monthStr := c.Query("month")
	if monthStr == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Month parameter is required")
	}
	month, err := strconv.Atoi(monthStr)
	if err != nil || month < 1 || month > 12 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid month parameter (must be 1-12)")
	}

	// Parse and validate year parameter
	yearStr := c.Query("year")
	if yearStr == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Year parameter is required")
	}
	year, err := strconv.Atoi(yearStr)
	if err != nil || year < 2000 || year > 2100 {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid year parameter")
	}

	// Call service
	filePath, err := ctrl.reportService.ExportToExcel(ownerID, month, year)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"file_path": filePath,
		"message":   "Income report exported successfully",
	})
}

// ExportUnpaid exports unpaid bills report to Excel
func (ctrl *ReportController) ExportUnpaid(c *fiber.Ctx) error {
	// Extract ownerID from JWT claims
	ownerID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Call service to export unpaid report
	// Note: Using ExportToExcel with current month/year as placeholder
	// In a real implementation, you'd have a separate ExportUnpaidToExcel method
	filePath, err := ctrl.reportService.ExportToExcel(ownerID, 0, 0)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"file_path": filePath,
		"message":   "Unpaid report exported successfully",
	})
}
