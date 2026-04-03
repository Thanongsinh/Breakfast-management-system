package routes

import (
	"rental-v3/backend/api/controllers"

	"github.com/gofiber/fiber/v2"
)

// SetupAdminRoutes sets up admin-related routes
func SetupAdminRoutes(app *fiber.App) {
	adminController := controllers.NewAdminController()
	notificationController := controllers.NewNotificationController()

	// TODO: Add auth middleware and role middleware (admin)
	admin := app.Group("/api/admin")

	// Dashboard routes
	admin.Get("/dashboard", adminController.Dashboard)
	admin.Get("/stats", adminController.GetStats)

	// Owner management routes
	owners := admin.Group("/owners")
	owners.Get("/", adminController.ListOwners)
	owners.Patch("/:id/status", adminController.UpdateOwnerStatus)

	// Notification routes
	notifications := admin.Group("/notifications")
	notifications.Post("/test-line", notificationController.TestLINE)
	notifications.Post("/payment-reminder", notificationController.SendPaymentReminder)
}
