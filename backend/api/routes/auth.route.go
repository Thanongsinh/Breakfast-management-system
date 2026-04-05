package routes

import (
	"rental-v3/backend/api/controllers"
	"rental-v3/backend/api/middleware"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
)

// SetupAuthRoutes sets up authentication-related routes
func SetupAuthRoutes(app *fiber.App, authService services.AuthService, userRepo *repositories.UserRepository, jwtSecret string) {
	authController := controllers.NewAuthController(authService, userRepo)

	auth := app.Group("/api/auth")

	// Public routes
	auth.Post("/login", authController.Login)
	auth.Post("/refresh", authController.Refresh)

	// Protected routes (require authentication)
	auth.Use(middleware.AuthMiddleware(jwtSecret))
	auth.Get("/me", authController.GetProfile)
	auth.Post("/logout", authController.Logout)
}
