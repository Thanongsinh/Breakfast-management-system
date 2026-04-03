package bootstrap

import (
	"github.com/redis/go-redis/v9"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

// App holds all application dependencies
type App struct {
	Config *Config
	DB     *gorm.DB
	Redis  *redis.Client
	MinIO  *minio.Client
}

// Init initializes all application dependencies
func Init() (*App, error) {
	// TODO: implement full app initialization

	// Load config
	config, err := LoadConfig()
	if err != nil {
		return nil, err
	}

	// Initialize database
	db, err := InitDB(config)
	if err != nil {
		return nil, err
	}

	// Initialize Redis
	redisClient, err := InitRedis(config)
	if err != nil {
		return nil, err
	}

	// Initialize MinIO
	minioClient, err := InitMinIO(config)
	if err != nil {
		return nil, err
	}

	return &App{
		Config: config,
		DB:     db,
		Redis:  redisClient,
		MinIO:  minioClient,
	}, nil
}
