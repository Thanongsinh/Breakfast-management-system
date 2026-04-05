package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/models"

	"github.com/gofiber/fiber/v2"
)

// AuthController handles authentication-related requests
type AuthController struct {
	authService services.AuthService
	userRepo    *repositories.UserRepository
}

// NewAuthController creates a new instance of AuthController
func NewAuthController(authService services.AuthService, userRepo *repositories.UserRepository) *AuthController {
	return &AuthController{
		authService: authService,
		userRepo:    userRepo,
	}
}

// Login handles user login
func (ctrl *AuthController) Login(c *fiber.Ctx) error {
	// Parse request body
	var req models.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.Email == "" || req.Password == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Email and password are required")
	}

	// Call auth service
	user, accessToken, refreshToken, err := ctrl.authService.Login(c.Context(), req.Email, req.Password)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, err.Error())
	}

	// Build response with accounts array for multi-account support
	accounts := []fiber.Map{
		{
			"id":    user.ID,
			"name":  user.Name,
			"email": user.Email,
			"role":  user.Role,
		},
	}

	return utilities.SuccessResponse(c, fiber.Map{
		"accessToken":  accessToken,
		"refreshToken": refreshToken,
		"user": models.UserResponse{
			ID:    user.ID,
			Name:  user.Name,
			Email: user.Email,
			Role:  user.Role,
			Phone: user.Phone,
		},
		"accounts": accounts,
	})
}

// Logout handles user logout
func (ctrl *AuthController) Logout(c *fiber.Ctx) error {
	// For JWT-based auth, logout is handled client-side by removing the token
	// Optionally: implement token blacklist with Redis
	return utilities.SuccessResponse(c, fiber.Map{
		"message": "Logged out successfully",
	})
}

// Refresh handles token refresh
func (ctrl *AuthController) Refresh(c *fiber.Ctx) error {
	// Parse request body
	var req models.RefreshRequest
	if err := c.BodyParser(&req); err != nil {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	// Validate request
	if req.RefreshToken == "" {
		return utilities.ErrorResponse(c, fiber.StatusBadRequest, "Refresh token is required")
	}

	// Call auth service
	newAccessToken, err := ctrl.authService.RefreshToken(c.Context(), req.RefreshToken)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, err.Error())
	}

	// Return new access token
	return utilities.SuccessResponse(c, fiber.Map{
		"access_token": newAccessToken,
	})
}

// GetProfile returns the current user's profile
func (ctrl *AuthController) GetProfile(c *fiber.Ctx) error {
	// Extract userID from JWT claims (set by auth middleware)
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Get user from repository
	user, err := ctrl.userRepo.FindByID(userID)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusNotFound, "User not found")
	}

	// Return user profile
	return utilities.SuccessResponse(c, models.UserResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
		Role:  user.Role,
		Phone: user.Phone,
	})
}
