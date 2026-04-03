package controllers

import (
	"github.com/gofiber/fiber/v2"
)

// ReportController handles report-related requests
type ReportController struct {
	// TODO: add report service dependency
}

// NewReportController creates a new instance of ReportController
func NewReportController() *ReportController {
	return &ReportController{}
}

// GetIncome generates income report
func (ctrl *ReportController) GetIncome(c *fiber.Ctx) error {
	// TODO: implement get income report logic
	return c.JSON(fiber.Map{
		"message": "Get income report endpoint",
	})
}

// GetUnpaid generates unpaid bills report
func (ctrl *ReportController) GetUnpaid(c *fiber.Ctx) error {
	// TODO: implement get unpaid report logic
	return c.JSON(fiber.Map{
		"message": "Get unpaid report endpoint",
	})
}

// ExportExcel exports report data to Excel
func (ctrl *ReportController) ExportExcel(c *fiber.Ctx) error {
	// TODO: implement export to Excel logic
	return c.JSON(fiber.Map{
		"message": "Export to Excel endpoint",
	})
}
