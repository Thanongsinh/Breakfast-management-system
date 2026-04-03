package middleware

import (
	"github.com/gofiber/fiber/v2"
)

// RequireRole returns a Fiber middleware handler for role-based access control
func RequireRole(role string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// TODO: Get user from context (set by AuthMiddleware)
		// user := c.Locals("user")
		// if user == nil {
		// 	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		// 		"error": "Unauthorized",
		// 	})
		// }

		// TODO: Check if user has required role
		// if user.Role != role {
		// 	return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
		// 		"error": "Insufficient permissions",
		// 	})
		// }

		_ = role // Placeholder to avoid unused variable error

		return c.Next()
	}
}
