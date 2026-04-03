package services

import (
	"context"
	"rental-v3/backend/domain/entities"
)

// ContractService defines methods for contract business logic
type ContractService interface {
	CreateContract(ctx context.Context, contract *entities.Contract) error
	GetByID(ctx context.Context, id string) (*entities.Contract, error)
	GenerateContractPDF(ctx context.Context, contractID string) ([]byte, error)
	List(ctx context.Context, limit, offset int) ([]*entities.Contract, error)
}

// contractServiceImpl is the concrete implementation of ContractService
type contractServiceImpl struct {
	// TODO: add dependencies (contract repository, storage service)
}

// NewContractService creates a new instance of ContractService
func NewContractService() ContractService {
	return &contractServiceImpl{}
}

func (s *contractServiceImpl) CreateContract(ctx context.Context, contract *entities.Contract) error {
	// TODO: implement
	return nil
}

func (s *contractServiceImpl) GetByID(ctx context.Context, id string) (*entities.Contract, error) {
	// TODO: implement
	return nil, nil
}

func (s *contractServiceImpl) GenerateContractPDF(ctx context.Context, contractID string) ([]byte, error) {
	// TODO: implement
	return nil, nil
}

func (s *contractServiceImpl) List(ctx context.Context, limit, offset int) ([]*entities.Contract, error) {
	// TODO: implement
	return nil, nil
}
