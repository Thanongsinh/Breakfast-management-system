package bootstrap

import (
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// InitMinIO initializes MinIO client and creates buckets
func InitMinIO(config *Config) (*minio.Client, error) {
	// TODO: implement MinIO initialization
	client, err := minio.New(config.MinIO.Endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(config.MinIO.AccessKey, config.MinIO.SecretKey, ""),
		Secure: config.MinIO.UseSSL,
	})

	if err != nil {
		return nil, err
	}

	// Create buckets if they don't exist
	// TODO: implement bucket creation logic

	return client, nil
}
