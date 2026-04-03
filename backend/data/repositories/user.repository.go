package repositories

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// UserRepository defines methods for user data access
type UserRepository interface {
	Create(ctx context.Context, user *entities.User) error
	FindByEmail(ctx context.Context, email string) (*entities.User, error)
	FindByID(ctx context.Context, id string) (*entities.User, error)
	Update(ctx context.Context, user *entities.User) error
	List(ctx context.Context, limit, offset int) ([]*entities.User, error)
}

// userRepositoryImpl is the concrete implementation of UserRepository
type userRepositoryImpl struct {
	// TODO: add database connection
}

// NewUserRepository creates a new instance of UserRepository
func NewUserRepository() UserRepository {
	return &userRepositoryImpl{}
}

func (r *userRepositoryImpl) Create(ctx context.Context, user *entities.User) error {
	// TODO: implement
	return nil
}

func (r *userRepositoryImpl) FindByEmail(ctx context.Context, email string) (*entities.User, error) {
	// TODO: implement
	return nil, nil
}

func (r *userRepositoryImpl) FindByID(ctx context.Context, id string) (*entities.User, error) {
	// TODO: implement
	return nil, nil
}

func (r *userRepositoryImpl) Update(ctx context.Context, user *entities.User) error {
	// TODO: implement
	return nil
}

func (r *userRepositoryImpl) List(ctx context.Context, limit, offset int) ([]*entities.User, error) {
	// TODO: implement
	return nil, nil
}
