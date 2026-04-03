package routes

import (
	"rental-v3/backend/api/controllers"

	"github.com/gofiber/fiber/v2"
)

// SetupTenantRoutes sets up tenant-related routes
func SetupTenantRoutes(app *fiber.App) {
	billController := controllers.NewBillController()
	paymentController := controllers.NewPaymentController()
	maintenanceController := controllers.NewMaintenanceController()

	// TODO: Add auth middleware and role middleware (tenant)
	tenant := app.Group("/api/tenant")

	// Bill routes
	bills := tenant.Group("/bills")
	bills.Get("/", billController.ListByTenant)
	bills.Get("/:id", billController.GetByID)

	// Payment routes
	payments := tenant.Group("/payments")
	payments.Get("/", paymentController.List)
	payments.Get("/:id", paymentController.GetByID)
	payments.Get("/:id/receipt", paymentController.GetReceipt)

	// Maintenance routes
	maintenance := tenant.Group("/maintenance")
	maintenance.Post("/", maintenanceController.Create)
	maintenance.Get("/", maintenanceController.List)
	maintenance.Get("/:id", maintenanceController.GetByID)
	maintenance.Post("/:id/images", maintenanceController.UploadImages)
}
