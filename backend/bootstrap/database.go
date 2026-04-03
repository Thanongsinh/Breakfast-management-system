package bootstrap

import (
	"fmt"
	"rental-v3/backend/domain/entities"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// InitDB initializes database connection and runs migrations
func InitDB(config *Config) (*gorm.DB, error) {
	// Build DSN from config
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		config.Database.Host,
		config.Database.User,
		config.Database.Password,
		config.Database.Name,
		config.Database.Port,
		config.Database.SSLMode,
	)

	// Configure GORM
	gormConfig := &gorm.Config{}

	// Enable logging in development mode
	if config.Server.Env == "development" {
		gormConfig.Logger = logger.Default.LogMode(logger.Info)
	} else {
		gormConfig.Logger = logger.Default.LogMode(logger.Silent)
	}

	// Open database connection
	db, err := gorm.Open(postgres.Open(dsn), gormConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Auto-migrate all entities
	err = db.AutoMigrate(
		&entities.User{},
		&entities.Building{},
		&entities.Room{},
		&entities.Tenant{},
		&entities.Contract{},
		&entities.Bill{},
		&entities.Payment{},
		&entities.MaintenanceRequest{},
	)
	if err != nil {
		return nil, fmt.Errorf("failed to run migrations: %w", err)
	}

	return db, nil
}
