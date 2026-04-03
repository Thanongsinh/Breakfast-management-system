package routes

import (
	"rental-v3/backend/api/middleware"

	"github.com/gofiber/fiber/v2"
)

// SetupRoutes sets up all application routes
func SetupRoutes(app *fiber.App) {
	// Apply global middleware
	app.Use(middleware.Logger())
	app.Use(middleware.CORS())
	app.Use(middleware.RateLimit())

	// Health check endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":  "ok",
			"message": "Rental Management System API is running",
		})
	})

	// Setup route groups
	SetupAuthRoutes(app)
	SetupOwnerRoutes(app)
	SetupTenantRoutes(app)
	SetupAdminRoutes(app)

	// 404 handler
	app.Use(func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Route not found",
		})
	})
}
