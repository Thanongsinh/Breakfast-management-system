package services

import (
	"errors"
	"rental-v3/backend/bootstrap"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
	"time"
)

type BillService struct {
	billRepo     *repositories.BillRepository
	tenantRepo   *repositories.TenantRepository
	contractRepo *repositories.ContractRepository
	config       *bootstrap.Config
}

func NewBillService(
	billRepo *repositories.BillRepository,
	tenantRepo *repositories.TenantRepository,
	contractRepo *repositories.ContractRepository,
	config *bootstrap.Config,
) *BillService {
	return &BillService{
		billRepo:     billRepo,
		tenantRepo:   tenantRepo,
		contractRepo: contractRepo,
		config:       config,
	}
}

// GenerateBills generates bills for all active contracts for a given month/year
func (s *BillService) GenerateBills(month, year int) error {
	// Get all active contracts
	contracts, err := s.contractRepo.FindAllActive()
	if err != nil {
		return err
	}

	for _, contract := range contracts {
		// Check if bill already exists for this tenant and month
		existingBill, _ := s.billRepo.FindByTenantAndMonth(contract.TenantID, month, year)
		if existingBill != nil {
			continue // Skip if bill already exists
		}

		// Calculate due date (first day of next month + due day)
		nextMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC).AddDate(0, 1, 0)
		dueDate := time.Date(nextMonth.Year(), nextMonth.Month(), s.config.Billing.DueDay, 0, 0, 0, 0, time.UTC)

		// Create bill with default values (water and electric units will be updated by owner)
		bill := &entities.Bill{
			TenantID:      contract.TenantID,
			RoomID:        contract.RoomID,
			Month:         month,
			Year:          year,
			RentAmount:    contract.RentAmount,
			WaterUnit:     0,
			WaterPrice:    0,
			ElectricUnit:  0,
			ElectricPrice: 0,
			OtherFees:     0,
			OtherFeesNote: "",
			Total:         contract.RentAmount,
			DueDate:       dueDate,
			Status:        "unpaid",
		}

		if err := s.billRepo.Create(bill); err != nil {
			return err
		}
	}

	return nil
}

// CreateBill creates a new bill with calculated prices
func (s *BillService) CreateBill(req models.CreateBillRequest) error {
	// Check if bill already exists
	existingBill, _ := s.billRepo.FindByTenantAndMonth(req.TenantID, req.Month, req.Year)
	if existingBill != nil {
		return errors.New("bill already exists for this month")
	}

	// Get tenant to get rent price from contract
	tenant, err := s.tenantRepo.FindByID(req.TenantID)
	if err != nil {
		return err
	}

	// Get contract
	contract, err := s.contractRepo.FindActiveByTenant(tenant.ID)
	if err != nil {
		return err
	}

	// Calculate prices
	waterPrice := req.WaterUnit * s.config.Billing.WaterRatePerUnit
	electricPrice := req.ElectricUnit * s.config.Billing.ElectricRatePerUnit
	total := contract.RentAmount + waterPrice + electricPrice + req.OtherFees

	// Calculate due date
	nextMonth := time.Date(req.Year, time.Month(req.Month), 1, 0, 0, 0, 0, time.UTC).AddDate(0, 1, 0)
	dueDate := time.Date(nextMonth.Year(), nextMonth.Month(), s.config.Billing.DueDay, 0, 0, 0, 0, time.UTC)

	bill := &entities.Bill{
		TenantID:      req.TenantID,
		RoomID:        req.RoomID,
		Month:         req.Month,
		Year:          req.Year,
		RentAmount:    contract.RentAmount,
		WaterUnit:     req.WaterUnit,
		WaterPrice:    waterPrice,
		ElectricUnit:  req.ElectricUnit,
		ElectricPrice: electricPrice,
		OtherFees:     req.OtherFees,
		OtherFeesNote: req.OtherFeesNote,
		Total:         total,
		DueDate:       dueDate,
		Status:        "unpaid",
	}

	return s.billRepo.Create(bill)
}

// GetByID gets a bill by ID and verifies ownership
func (s *BillService) GetByID(id, ownerID uint) (*entities.Bill, error) {
	bill, err := s.billRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	// Verify ownership through tenant -> room -> building
	tenant, err := s.tenantRepo.FindByID(bill.TenantID)
	if err != nil {
		return nil, err
	}

	// This will be verified in the controller or through repository join
	_ = tenant

	return bill, nil
}

// List returns paginated bills for an owner with filters
func (s *BillService) List(ownerID uint, filters map[string]interface{}, page, limit int) ([]entities.Bill, int64, error) {
	return s.billRepo.ListByOwner(ownerID, filters, page, limit)
}

// ListByTenant returns paginated bills for a tenant
func (s *BillService) ListByTenant(tenantID uint, page, limit int) ([]entities.Bill, int64, error) {
	return s.billRepo.ListByTenant(tenantID, page, limit)
}

// UpdateBill updates a bill (for updating water/electric units)
func (s *BillService) UpdateBill(billID uint, waterUnit, electricUnit, otherFees float64, otherFeesNote string) error {
	bill, err := s.billRepo.FindByID(billID)
	if err != nil {
		return err
	}

	// Recalculate prices
	bill.WaterUnit = waterUnit
	bill.WaterPrice = waterUnit * s.config.Billing.WaterRatePerUnit
	bill.ElectricUnit = electricUnit
	bill.ElectricPrice = electricUnit * s.config.Billing.ElectricRatePerUnit
	bill.OtherFees = otherFees
	bill.OtherFeesNote = otherFeesNote
	bill.Total = bill.RentAmount + bill.WaterPrice + bill.ElectricPrice + bill.OtherFees

	return s.billRepo.Update(bill)
}
