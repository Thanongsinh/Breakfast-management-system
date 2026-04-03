package routes

import (
	"rental-v3/backend/api/controllers"

	"github.com/gofiber/fiber/v2"
)

// SetupAuthRoutes sets up authentication-related routes
func SetupAuthRoutes(app *fiber.App) {
	authController := controllers.NewAuthController()

	auth := app.Group("/api/auth")

	// Public routes
	auth.Post("/login", authController.Login)
	auth.Post("/logout", authController.Logout)
	auth.Post("/refresh", authController.Refresh)

	// Protected routes
	// TODO: Add auth middleware
	auth.Get("/profile", authController.GetProfile)
}
