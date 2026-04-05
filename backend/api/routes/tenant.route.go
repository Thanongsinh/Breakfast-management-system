package routes

import (
	"rental-v3/backend/api/controllers"
	"rental-v3/backend/api/middleware"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
)

// SetupTenantRoutes sets up tenant-related routes
func SetupTenantRoutes(
	app *fiber.App,
	billService *services.BillService,
	paymentService *services.PaymentService,
	maintenanceService *services.MaintenanceService,
	contractService *services.ContractService,
	jwtSecret string,
) {
	// Initialize controllers with service dependencies
	billController := controllers.NewBillController(billService)
	paymentController := controllers.NewPaymentController(paymentService)
	maintenanceController := controllers.NewMaintenanceController(maintenanceService)

	// Tenant group with auth and role middleware
	tenant := app.Group("/api/tenant")
	tenant.Use(middleware.AuthMiddleware(jwtSecret))
	tenant.Use(middleware.RequireRole("tenant"))

	// Bill routes
	bills := tenant.Group("/bills")
	bills.Get("/", billController.List)
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
