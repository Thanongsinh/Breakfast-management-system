package services

import (
	"context"
	"errors"
	"rental-v3/backend/bootstrap"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// AuthService defines methods for authentication operations
type AuthService interface {
	Login(ctx context.Context, email, password string) (*entities.User, string, string, error)
	GenerateJWT(user *entities.User, expireHours int) (string, error)
	ValidateJWT(ctx context.Context, token string) (*entities.User, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, error)
}

// authServiceImpl is the concrete implementation of AuthService
type authServiceImpl struct {
	userRepo *repositories.UserRepository
	config   *bootstrap.Config
}

// NewAuthService creates a new instance of AuthService
func NewAuthService(userRepo *repositories.UserRepository, config *bootstrap.Config) AuthService {
	return &authServiceImpl{
		userRepo: userRepo,
		config:   config,
	}
}

// Login authenticates a user and returns user data with JWT tokens
func (s *authServiceImpl) Login(ctx context.Context, email, password string) (*entities.User, string, string, error) {
	// Find user by email
	user, err := s.userRepo.FindByEmail(email)
	if err != nil {
		return nil, "", "", errors.New("invalid credentials")
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, "", "", errors.New("invalid credentials")
	}

	// Generate access token (24 hours)
	accessToken, err := s.GenerateJWT(user, s.config.JWT.AccessExpireHrs)
	if err != nil {
		return nil, "", "", errors.New("failed to generate access token")
	}

	// Generate refresh token (30 days)
	refreshToken, err := s.GenerateJWT(user, s.config.JWT.RefreshExpireDays*24)
	if err != nil {
		return nil, "", "", errors.New("failed to generate refresh token")
	}

	return user, accessToken, refreshToken, nil
}

// GenerateJWT generates a JWT token for the given user
func (s *authServiceImpl) GenerateJWT(user *entities.User, expireHours int) (string, error) {
	claims := jwt.MapClaims{
		"user_id": user.ID,
		"email":   user.Email,
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * time.Duration(expireHours)).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.config.JWT.Secret))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// ValidateJWT validates a JWT token and returns the associated user
func (s *authServiceImpl) ValidateJWT(ctx context.Context, tokenString string) (*entities.User, error) {
	// Parse token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Validate signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid signing method")
		}
		return []byte(s.config.JWT.Secret), nil
	})

	if err != nil {
		return nil, errors.New("invalid token")
	}

	// Extract claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	// Get user ID from claims
	userID, ok := claims["user_id"].(float64)
	if !ok {
		return nil, errors.New("invalid user_id in token")
	}

	// Find user by ID
	user, err := s.userRepo.FindByID(uint(userID))
	if err != nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

// RefreshToken validates a refresh token and generates a new access token
func (s *authServiceImpl) RefreshToken(ctx context.Context, refreshToken string) (string, error) {
	// Validate refresh token
	user, err := s.ValidateJWT(ctx, refreshToken)
	if err != nil {
		return "", errors.New("invalid refresh token")
	}

	// Generate new access token
	accessToken, err := s.GenerateJWT(user, s.config.JWT.AccessExpireHrs)
	if err != nil {
		return "", errors.New("failed to generate access token")
	}

	return accessToken, nil
}
