package main

import (
	"fmt"
	"log"
	"rental-v3/backend/bootstrap"
	"rental-v3/backend/domain/entities"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func main() {
	// Load config
	config, err := bootstrap.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize database
	db, err := bootstrap.InitDB(config)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	fmt.Println("🌱 Seeding default users...")

	// Create default users
	if err := seedDefaultUsers(db); err != nil {
		log.Fatalf("Failed to seed users: %v", err)
	}

	fmt.Println("✅ Default users created successfully!")
	fmt.Println("\n📋 Default User Credentials:")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	fmt.Println("👤 Admin:")
	fmt.Println("   Email:    admin@rental.com")
	fmt.Println("   Password: admin123")
	fmt.Println()
	fmt.Println("🏠 Owner:")
	fmt.Println("   Email:    owner@rental.com")
	fmt.Println("   Password: owner123")
	fmt.Println()
	fmt.Println("🏢 Tenant:")
	fmt.Println("   Email:    tenant@rental.com")
	fmt.Println("   Password: tenant123")
	fmt.Println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
}

func seedDefaultUsers(db *gorm.DB) error {
	users := []struct {
		Name     string
		Email    string
		Password string
		Role     string
		Phone    string
	}{
		{
			Name:     "Admin User",
			Email:    "admin@rental.com",
			Password: "admin123",
			Role:     "admin",
			Phone:    "081-234-5678",
		},
		{
			Name:     "John Owner",
			Email:    "owner@rental.com",
			Password: "owner123",
			Role:     "owner",
			Phone:    "082-345-6789",
		},
		{
			Name:     "Jane Tenant",
			Email:    "tenant@rental.com",
			Password: "tenant123",
			Role:     "tenant",
			Phone:    "083-456-7890",
		},
	}

	for _, u := range users {
		// Check if user already exists
		var existingUser entities.User
		result := db.Where("email = ?", u.Email).First(&existingUser)

		if result.Error == nil {
			// User exists, update it
			fmt.Printf("⚠️  User %s already exists, updating...\n", u.Email)

			// Hash password
			hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
			if err != nil {
				return fmt.Errorf("failed to hash password for %s: %w", u.Email, err)
			}

			// Update user
			existingUser.Name = u.Name
			existingUser.PasswordHash = string(hashedPassword)
			existingUser.Role = u.Role
			existingUser.Phone = u.Phone

			if err := db.Save(&existingUser).Error; err != nil {
				return fmt.Errorf("failed to update user %s: %w", u.Email, err)
			}
		} else if result.Error == gorm.ErrRecordNotFound {
			// User doesn't exist, create new
			fmt.Printf("✨ Creating new user: %s (%s)\n", u.Email, u.Role)

			// Hash password
			hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
			if err != nil {
				return fmt.Errorf("failed to hash password for %s: %w", u.Email, err)
			}

			// Create user
			newUser := entities.User{
				Name:         u.Name,
				Email:        u.Email,
				PasswordHash: string(hashedPassword),
				Role:         u.Role,
				Phone:        u.Phone,
			}

			if err := db.Create(&newUser).Error; err != nil {
				return fmt.Errorf("failed to create user %s: %w", u.Email, err)
			}
		} else {
			return fmt.Errorf("failed to check user %s: %w", u.Email, result.Error)
		}
	}

	return nil
}
