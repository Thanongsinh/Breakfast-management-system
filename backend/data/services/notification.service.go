package services

import (
	"context"
)

// NotificationService defines methods for notification operations
type NotificationService interface {
	SendLINENotify(ctx context.Context, token, message string) error
}

// notificationServiceImpl is the concrete implementation of NotificationService
type notificationServiceImpl struct {
	// TODO: add notification configuration
}

// NewNotificationService creates a new instance of NotificationService
func NewNotificationService() NotificationService {
	return &notificationServiceImpl{}
}

func (s *notificationServiceImpl) SendLINENotify(ctx context.Context, token, message string) error {
	// TODO: implement
	return nil
}
