package routes

import (
	"rental-v3/backend/api/controllers"
	"rental-v3/backend/api/middleware"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
)

// SetupOwnerRoutes sets up owner-related routes
func SetupOwnerRoutes(
	app *fiber.App,
	buildingService *services.BuildingService,
	roomService *services.RoomService,
	tenantService *services.TenantService,
	contractService *services.ContractService,
	billService *services.BillService,
	paymentService *services.PaymentService,
	maintenanceService *services.MaintenanceService,
	reportService *services.ReportService,
	jwtSecret string,
) {
	// Initialize controllers with service dependencies
	buildingController := controllers.NewBuildingController(buildingService)
	roomController := controllers.NewRoomController(roomService)
	tenantController := controllers.NewTenantController(tenantService)
	contractController := controllers.NewContractController(contractService)
	billController := controllers.NewBillController(billService)
	paymentController := controllers.NewPaymentController(paymentService)
	maintenanceController := controllers.NewMaintenanceController(maintenanceService)
	reportController := controllers.NewReportController(reportService)

	// Owner group with auth and role middleware
	owner := app.Group("/api/owner")
	owner.Use(middleware.AuthMiddleware(jwtSecret))
	owner.Use(middleware.RequireRole("owner"))

	// Building routes
	buildings := owner.Group("/buildings")
	buildings.Post("/", buildingController.Create)
	buildings.Get("/", buildingController.List)
	buildings.Get("/:id", buildingController.GetByID)
	buildings.Put("/:id", buildingController.Update)
	buildings.Delete("/:id", buildingController.Delete)

	// Room routes
	rooms := owner.Group("/rooms")
	rooms.Post("/", roomController.Create)
	rooms.Get("/building/:buildingId", roomController.ListByBuilding)
	rooms.Get("/:id", roomController.GetByID)
	rooms.Put("/:id", roomController.Update)
	rooms.Delete("/:id", roomController.Delete)
	rooms.Patch("/:id/status", roomController.UpdateStatus)

	// Tenant routes
	tenants := owner.Group("/tenants")
	tenants.Post("/", tenantController.Create)
	tenants.Get("/", tenantController.List)
	tenants.Get("/:id", tenantController.GetByID)
	tenants.Put("/:id", tenantController.Update)
	tenants.Delete("/:id", tenantController.Delete)

	// Contract routes
	contracts := owner.Group("/contracts")
	contracts.Post("/", contractController.Create)
	contracts.Get("/", contractController.List)
	contracts.Get("/:id", contractController.GetByID)
	contracts.Get("/:id/pdf", contractController.GetPDF)

	// Bill routes
	bills := owner.Group("/bills")
	bills.Get("/", billController.List)
	bills.Get("/:id", billController.GetByID)
	bills.Post("/generate", billController.GenerateBills)

	// Payment routes
	payments := owner.Group("/payments")
	payments.Post("/confirm-cash", paymentController.ConfirmCash)
	payments.Get("/", paymentController.List)
	payments.Get("/:id", paymentController.GetByID)
	payments.Get("/:id/receipt", paymentController.GetReceipt)

	// Maintenance routes
	maintenance := owner.Group("/maintenance")
	maintenance.Get("/", maintenanceController.List)
	maintenance.Get("/:id", maintenanceController.GetByID)
	maintenance.Put("/:id", maintenanceController.Update)

	// Report routes
	reports := owner.Group("/reports")
	reports.Get("/income", reportController.GetIncomeReport)
	reports.Get("/unpaid", reportController.GetUnpaidReport)
	reports.Get("/income/export", reportController.ExportIncome)
	reports.Get("/unpaid/export", reportController.ExportUnpaid)
}
