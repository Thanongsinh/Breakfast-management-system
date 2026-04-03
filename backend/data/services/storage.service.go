package services

import (
	"context"
	"io"
)

// StorageService defines methods for file storage operations
type StorageService interface {
	UploadFile(ctx context.Context, fileName string, file io.Reader) (string, error)
	DownloadFile(ctx context.Context, fileURL string) (io.ReadCloser, error)
	DeleteFile(ctx context.Context, fileURL string) error
}

// storageServiceImpl is the concrete implementation of StorageService
type storageServiceImpl struct {
	// TODO: add storage configuration
}

// NewStorageService creates a new instance of StorageService
func NewStorageService() StorageService {
	return &storageServiceImpl{}
}

func (s *storageServiceImpl) UploadFile(ctx context.Context, fileName string, file io.Reader) (string, error) {
	// TODO: implement
	return "", nil
}

func (s *storageServiceImpl) DownloadFile(ctx context.Context, fileURL string) (io.ReadCloser, error) {
	// TODO: implement
	return nil, nil
}

func (s *storageServiceImpl) DeleteFile(ctx context.Context, fileURL string) error {
	// TODO: implement
	return nil
}
