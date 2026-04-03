package repositories

import (
	"rental-v3/backend/domain/entities"

	"gorm.io/gorm"
)

// UserRepository defines methods for user data access
type UserRepository struct {
	DB *gorm.DB
}

// NewUserRepository creates a new instance of UserRepository
func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{DB: db}
}

// Create creates a new user
func (r *UserRepository) Create(user *entities.User) error {
	return r.DB.Create(user).Error
}

// FindByEmail finds a user by email
func (r *UserRepository) FindByEmail(email string) (*entities.User, error) {
	var user entities.User
	err := r.DB.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByID finds a user by ID
func (r *UserRepository) FindByID(id uint) (*entities.User, error) {
	var user entities.User
	err := r.DB.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Update updates a user
func (r *UserRepository) Update(user *entities.User) error {
	return r.DB.Save(user).Error
}

// List returns a paginated list of users
func (r *UserRepository) List(limit, offset int) ([]*entities.User, int64, error) {
	var users []*entities.User
	var total int64

	// Count total
	if err := r.DB.Model(&entities.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := r.DB.Offset(offset).Limit(limit).Find(&users).Error
	return users, total, err
}

// ListByRole returns users filtered by role
func (r *UserRepository) ListByRole(role string, limit, offset int) ([]*entities.User, int64, error) {
	var users []*entities.User
	var total int64

	query := r.DB.Where("role = ?", role)

	// Count total
	if err := query.Model(&entities.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := query.Offset(offset).Limit(limit).Find(&users).Error
	return users, total, err
}

// Delete soft deletes a user (if soft delete is implemented)
func (r *UserRepository) Delete(id uint) error {
	return r.DB.Delete(&entities.User{}, id).Error
}
