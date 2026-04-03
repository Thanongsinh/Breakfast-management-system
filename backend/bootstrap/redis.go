package bootstrap

import (
	"context"
	"github.com/redis/go-redis/v9"
)

// InitRedis initializes Redis client and tests connection
func InitRedis(config *Config) (*redis.Client, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     config.Redis.Host + ":" + config.Redis.Port,
		Password: config.Redis.Password,
		DB:       config.Redis.DB,
	})

	// Test connection
	ctx := context.Background()
	if _, err := client.Ping(ctx).Result(); err != nil {
		return nil, err
	}

	return client, nil
}
