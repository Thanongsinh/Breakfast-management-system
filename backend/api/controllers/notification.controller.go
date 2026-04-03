package controllers

import (
	"github.com/gofiber/fiber/v2"
)

// NotificationController handles notification-related requests
type NotificationController struct {
	// TODO: add notification service dependency
}

// NewNotificationController creates a new instance of NotificationController
func NewNotificationController() *NotificationController {
	return &NotificationController{}
}

// TestLINE handles LINE notification testing
func (ctrl *NotificationController) TestLINE(c *fiber.Ctx) error {
	// TODO: implement test LINE notification logic
	return c.JSON(fiber.Map{
		"message": "Test LINE notification endpoint",
	})
}

// SendPaymentReminder sends payment reminder notifications
func (ctrl *NotificationController) SendPaymentReminder(c *fiber.Ctx) error {
	// TODO: implement send payment reminder logic
	return c.JSON(fiber.Map{
		"message": "Send payment reminder endpoint",
	})
}
