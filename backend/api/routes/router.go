package routes

import (
	"github.com/gofiber/fiber/v2"
)

// SetupRoutes sets up all application routes
// NOTE: This file is deprecated - routes are now set up with dependency injection in main.go
// Keeping this file for reference but all functions are commented out
func SetupRoutes(app *fiber.App) {
	// Deprecated - see main.go for new approach with dependency injection

	// Apply global middleware
	// app.Use(middleware.Logger())
	// app.Use(middleware.CORS())
	// app.Use(middleware.RateLimit())

	// Health check endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":  "ok",
			"message": "Rental Management System API is running",
		})
	})

	// Setup route groups - now done in main.go with DI
	// SetupAuthRoutes(app, authService, userRepo, jwtSecret)
	// SetupOwnerRoutes(app, ...)
	// SetupTenantRoutes(app, ...)
	// SetupAdminRoutes(app, ...)

	// 404 handler
	app.Use(func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Route not found",
		})
	})
}
