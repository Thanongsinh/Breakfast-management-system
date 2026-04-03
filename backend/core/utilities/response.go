package utilities

import "github.com/gofiber/fiber/v2"

type Response struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

type PaginatedData struct {
	Success    bool        `json:"success"`
	Data       interface{} `json:"data"`
	Pagination interface{} `json:"pagination"`
}

// SuccessResponse returns a success response
func SuccessResponse(c *fiber.Ctx, data interface{}) error {
	return c.JSON(Response{
		Success: true,
		Data:    data,
	})
}

// ErrorResponse returns an error response
func ErrorResponse(c *fiber.Ctx, statusCode int, message string) error {
	return c.Status(statusCode).JSON(Response{
		Success: false,
		Error:   message,
	})
}

// PaginatedResponse returns a paginated response
func PaginatedResponse(c *fiber.Ctx, data interface{}, pagination interface{}) error {
	return c.JSON(PaginatedData{
		Success:    true,
		Data:       data,
		Pagination: pagination,
	})
}
