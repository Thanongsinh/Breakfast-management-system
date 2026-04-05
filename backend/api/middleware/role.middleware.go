package middleware

import (
	"github.com/gofiber/fiber/v2"
)

// RequireRole returns a Fiber middleware handler for role-based access control
// Supports multiple allowed roles (variadic parameter)
func RequireRole(allowedRoles ...string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get role from context (set by AuthMiddleware)
		role, ok := c.Locals("role").(string)
		if !ok || role == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"success": false,
				"error":   "Unauthorized",
			})
		}

		// Check if user has any of the required roles
		hasAccess := false
		for _, allowedRole := range allowedRoles {
			if role == allowedRole {
				hasAccess = true
				break
			}
		}

		if !hasAccess {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"success": false,
				"error":   "Insufficient permissions",
			})
		}

		return c.Next()
	}
}
