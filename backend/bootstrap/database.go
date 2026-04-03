package bootstrap

import (
	"gorm.io/gorm"
	"gorm.io/driver/postgres"
	"rental-backend/domain/entities"
)

// InitDB initializes database connection and runs migrations
func InitDB(config *Config) (*gorm.DB, error) {
	// TODO: implement database initialization
	dsn := "" // Build DSN from config
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
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

	return db, err
}
