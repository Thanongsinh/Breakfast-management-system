package services

import (
	"errors"
	"fmt"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"time"
)

type ContractService struct {
	contractRepo *repositories.ContractRepository
	tenantRepo   *repositories.TenantRepository
	roomRepo     *repositories.RoomRepository
	buildingRepo *repositories.BuildingRepository
	storageService StorageService
}

func NewContractService(
	contractRepo *repositories.ContractRepository,
	tenantRepo *repositories.TenantRepository,
	roomRepo *repositories.RoomRepository,
	buildingRepo *repositories.BuildingRepository,
	storageService StorageService,
) *ContractService {
	return &ContractService{
		contractRepo:   contractRepo,
		tenantRepo:     tenantRepo,
		roomRepo:       roomRepo,
		buildingRepo:   buildingRepo,
		storageService: storageService,
	}
}

// Create creates a new contract
func (s *ContractService) Create(ownerID uint, contract *entities.Contract) error {
	// Verify ownership through room
	room, err := s.roomRepo.FindByID(contract.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this room")
	}

	// Set default status
	if contract.Status == "" {
		contract.Status = "active"
	}

	// Create contract
	if err := s.contractRepo.Create(contract); err != nil {
		return err
	}

	// Update tenant's contract_id
	tenant, err := s.tenantRepo.FindByID(contract.TenantID)
	if err != nil {
		return err
	}
	tenant.ContractID = contract.ID
	if err := s.tenantRepo.Update(tenant); err != nil {
		return err
	}

	return nil
}

// GetByID gets a contract by ID
func (s *ContractService) GetByID(id, ownerID uint) (*entities.Contract, error) {
	contract, err := s.contractRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	// Verify ownership
	room, err := s.roomRepo.FindByID(contract.RoomID)
	if err != nil {
		return nil, err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return nil, err
	}

	if building.OwnerID != ownerID {
		return nil, errors.New("forbidden: not the owner of this contract")
	}

	return contract, nil
}

// List returns paginated contracts for an owner
func (s *ContractService) List(ownerID uint, page, limit int) ([]entities.Contract, int64, error) {
	return s.contractRepo.List(ownerID, page, limit)
}

// Update updates a contract
func (s *ContractService) Update(id, ownerID uint, contract *entities.Contract) error {
	existing, err := s.contractRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership
	room, err := s.roomRepo.FindByID(existing.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this contract")
	}

	contract.ID = id
	return s.contractRepo.Update(contract)
}

// GenerateContractPDF generates a contract PDF (simplified version)
func (s *ContractService) GenerateContractPDF(contractID uint) (string, error) {
	contract, err := s.contractRepo.FindByID(contractID)
	if err != nil {
		return "", err
	}

	// In a real implementation, this would generate a PDF using the PDF utility
	// For now, we'll just return a placeholder path
	pdfPath := fmt.Sprintf("contracts/contract-%d-%d.pdf", contractID, time.Now().Unix())

	// Update contract with PDF path
	contract.PDFPath = pdfPath
	if err := s.contractRepo.Update(contract); err != nil {
		return "", err
	}

	return pdfPath, nil
}
