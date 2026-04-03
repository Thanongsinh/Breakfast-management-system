package services

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// AuthService defines methods for authentication operations
type AuthService interface {
	Login(ctx context.Context, email, password string) (*entities.User, string, error)
	GenerateJWT(ctx context.Context, user *entities.User) (string, error)
	ValidateJWT(ctx context.Context, token string) (*entities.User, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, error)
}

// authServiceImpl is the concrete implementation of AuthService
type authServiceImpl struct {
	// TODO: add dependencies (user repository, jwt config)
}

// NewAuthService creates a new instance of AuthService
func NewAuthService() AuthService {
	return &authServiceImpl{}
}

func (s *authServiceImpl) Login(ctx context.Context, email, password string) (*entities.User, string, error) {
	// TODO: implement
	return nil, "", nil
}

func (s *authServiceImpl) GenerateJWT(ctx context.Context, user *entities.User) (string, error) {
	// TODO: implement
	return "", nil
}

func (s *authServiceImpl) ValidateJWT(ctx context.Context, token string) (*entities.User, error) {
	// TODO: implement
	return nil, nil
}

func (s *authServiceImpl) RefreshToken(ctx context.Context, refreshToken string) (string, error) {
	// TODO: implement
	return "", nil
}
