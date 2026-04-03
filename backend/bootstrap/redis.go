package bootstrap

import (
	"context"
	"github.com/redis/go-redis/v9"
)

// InitRedis initializes Redis client
func InitRedis(config *Config) (*redis.Client, error) {
	// TODO: implement Redis initialization
	client := redis.NewClient(&redis.Options{
		Addr:     config.Redis.Host + ":" + config.Redis.Port,
		Password: config.Redis.Password,
		DB:       config.Redis.DB,
	})

	// Test connection
	ctx := context.Background()
	_, err := client.Ping(ctx).Result()

	return client, err
}
