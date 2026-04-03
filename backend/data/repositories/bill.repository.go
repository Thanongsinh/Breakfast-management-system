package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type BillRepository struct {
	DB *gorm.DB
}

func NewBillRepository(db *gorm.DB) *BillRepository {
	return &BillRepository{DB: db}
}

// Create creates a new bill
func (r *BillRepository) Create(bill *entities.Bill) error {
	return r.DB.Create(bill).Error
}

// FindByID finds a bill by ID with preloaded relationships
func (r *BillRepository) FindByID(id uint) (*entities.Bill, error) {
	var bill entities.Bill
	err := r.DB.Preload("Tenant").Preload("Room").First(&bill, id).Error
	if err != nil {
		return nil, err
	}
	return &bill, nil
}

// Update updates a bill
func (r *BillRepository) Update(bill *entities.Bill) error {
	return r.DB.Save(bill).Error
}

// ListByTenant returns paginated list of bills for a tenant
func (r *BillRepository) ListByTenant(tenantID uint, page, limit int) ([]entities.Bill, int64, error) {
	var bills []entities.Bill
	var total int64

	offset := (page - 1) * limit

	// Count total
	if err := r.DB.Model(&entities.Bill{}).Where("tenant_id = ?", tenantID).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := r.DB.Where("tenant_id = ?", tenantID).
		Preload("Tenant").Preload("Room").
		Order("year DESC, month DESC").
		Offset(offset).Limit(limit).
		Find(&bills).Error

	if err != nil {
		return nil, 0, err
	}

	return bills, total, nil
}

// ListByOwner returns paginated list of bills for an owner with filters
func (r *BillRepository) ListByOwner(ownerID uint, filters map[string]interface{}, page, limit int) ([]entities.Bill, int64, error) {
	var bills []entities.Bill
	var total int64

	offset := (page - 1) * limit

	// Build query with joins
	query := r.DB.Model(&entities.Bill{}).
		Joins("JOIN tenants ON tenants.id = bills.tenant_id").
		Joins("JOIN rooms ON rooms.id = tenants.room_id").
		Joins("JOIN buildings ON buildings.id = rooms.building_id").
		Where("buildings.owner_id = ?", ownerID)

	// Apply filters
	if status, ok := filters["status"].(string); ok && status != "" {
		query = query.Where("bills.status = ?", status)
	}
	if month, ok := filters["month"].(int); ok && month > 0 {
		query = query.Where("bills.month = ?", month)
	}
	if year, ok := filters["year"].(int); ok && year > 0 {
		query = query.Where("bills.year = ?", year)
	}

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := query.
		Preload("Tenant").Preload("Room").
		Order("bills.year DESC, bills.month DESC").
		Offset(offset).Limit(limit).
		Find(&bills).Error

	if err != nil {
		return nil, 0, err
	}

	return bills, total, nil
}

// ListUnpaid returns all unpaid or overdue bills for an owner
func (r *BillRepository) ListUnpaid(ownerID uint) ([]entities.Bill, error) {
	var bills []entities.Bill

	err := r.DB.
		Joins("JOIN tenants ON tenants.id = bills.tenant_id").
		Joins("JOIN rooms ON rooms.id = tenants.room_id").
		Joins("JOIN buildings ON buildings.id = rooms.building_id").
		Where("buildings.owner_id = ? AND bills.status IN (?)", ownerID, []string{"unpaid", "overdue"}).
		Preload("Tenant").Preload("Room").
		Order("bills.due_date ASC").
		Find(&bills).Error

	if err != nil {
		return nil, err
	}

	return bills, nil
}

// FindByTenantAndMonth finds a bill for a specific tenant and month
func (r *BillRepository) FindByTenantAndMonth(tenantID uint, month, year int) (*entities.Bill, error) {
	var bill entities.Bill
	err := r.DB.Where("tenant_id = ? AND month = ? AND year = ?", tenantID, month, year).
		First(&bill).Error
	if err != nil {
		return nil, err
	}
	return &bill, nil
}
