package services

import (
	"context"
)

// CronService defines methods for scheduled task management
type CronService interface {
	Setup(ctx context.Context) error
	StartMonthlyBillGeneration(ctx context.Context) error
	StartPaymentReminders(ctx context.Context) error
	Stop(ctx context.Context) error
}

// cronServiceImpl is the concrete implementation of CronService
type cronServiceImpl struct {
	// TODO: add dependencies (bill service, notification service)
}

// NewCronService creates a new instance of CronService
func NewCronService() CronService {
	return &cronServiceImpl{}
}

func (s *cronServiceImpl) Setup(ctx context.Context) error {
	// TODO: implement
	return nil
}

func (s *cronServiceImpl) StartMonthlyBillGeneration(ctx context.Context) error {
	// TODO: implement
	return nil
}

func (s *cronServiceImpl) StartPaymentReminders(ctx context.Context) error {
	// TODO: implement
	return nil
}

func (s *cronServiceImpl) Stop(ctx context.Context) error {
	// TODO: implement
	return nil
}
