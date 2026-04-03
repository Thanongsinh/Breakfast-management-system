package bootstrap

import (
	"context"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// InitMinIO initializes MinIO client and creates buckets
func InitMinIO(config *Config) (*minio.Client, error) {
	// Initialize MinIO client
	client, err := minio.New(config.MinIO.Endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(config.MinIO.AccessKey, config.MinIO.SecretKey, ""),
		Secure: config.MinIO.UseSSL,
	})
	if err != nil {
		return nil, err
	}

	// Create context
	ctx := context.Background()

	// List of buckets to create
	buckets := []string{
		config.MinIO.Buckets.Receipts,
		config.MinIO.Buckets.Contracts,
		config.MinIO.Buckets.Maintenance,
	}

	// Create buckets if they don't exist
	for _, bucketName := range buckets {
		exists, err := client.BucketExists(ctx, bucketName)
		if err != nil {
			return nil, err
		}

		if !exists {
			err = client.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
			if err != nil {
				return nil, err
			}
		}
	}

	return client, nil
}
