package routes

import (
	"rental-v3/backend/api/controllers"
	"rental-v3/backend/api/middleware"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
)

// SetupAdminRoutes sets up admin-related routes
func SetupAdminRoutes(
	app *fiber.App,
	paymentService *services.PaymentService,
	notificationService *services.NotificationService,
	userRepo *repositories.UserRepository,
	paymentRepo *repositories.PaymentRepository,
	buildingRepo *repositories.BuildingRepository,
	roomRepo *repositories.RoomRepository,
	billRepo *repositories.BillRepository,
	jwtSecret string,
) {
	// Initialize controllers with service dependencies
	adminController := controllers.NewAdminController(paymentService, paymentRepo, userRepo, buildingRepo, roomRepo, billRepo)
	notificationController := controllers.NewNotificationController(notificationService)

	// Admin group with auth and role middleware
	admin := app.Group("/api/admin")
	admin.Use(middleware.AuthMiddleware(jwtSecret))
	admin.Use(middleware.RequireRole("admin"))

	// Dashboard routes
	admin.Get("/dashboard", adminController.GetDashboard)

	// Payment routes
	payments := admin.Group("/payments")
	payments.Get("/", adminController.ListAllPayments)

	// Owner management routes
	owners := admin.Group("/owners")
	owners.Get("/", adminController.ListOwners)

	// Notification routes
	notifications := admin.Group("/notifications")
	notifications.Post("/bill-reminder", notificationController.SendBillReminder)
	notifications.Post("/payment-confirmation", notificationController.SendPaymentConfirmation)
}
