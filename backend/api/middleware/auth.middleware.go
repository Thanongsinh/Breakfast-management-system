package middleware

import (
	"github.com/gofiber/fiber/v2"
	"strings"
)

// AuthMiddleware returns a Fiber middleware handler for JWT validation
func AuthMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get Authorization header
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Missing authorization header",
			})
		}

		// Check if Bearer token
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid authorization header format",
			})
		}

		token := parts[1]

		// TODO: Validate JWT token
		// TODO: Extract user information from token
		// TODO: Set user context in c.Locals("user", user)

		_ = token // Placeholder to avoid unused variable error

		return c.Next()
	}
}
