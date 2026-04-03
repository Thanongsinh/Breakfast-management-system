package middleware

import (
	"github.com/gofiber/fiber/v2"
)

// TenantScope returns a Fiber middleware handler for tenant data isolation
func TenantScope() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// TODO: Get user from context (set by AuthMiddleware)
		// user := c.Locals("user")
		// if user == nil {
		// 	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		// 		"error": "Unauthorized",
		// 	})
		// }

		// TODO: Set tenant scope in context
		// This ensures users can only access their own data
		// c.Locals("tenantID", user.TenantID)
		// c.Locals("ownerID", user.OwnerID)

		return c.Next()
	}
}
