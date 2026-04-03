package repositories

import (
	"rental-v3/backend/domain/entities"
	"gorm.io/gorm"
)

type PaymentRepository struct {
	DB *gorm.DB
}

func NewPaymentRepository(db *gorm.DB) *PaymentRepository {
	return &PaymentRepository{DB: db}
}

// Create creates a new payment
func (r *PaymentRepository) Create(payment *entities.Payment) error {
	return r.DB.Create(payment).Error
}

// FindByID finds a payment by ID with preloaded relationships
func (r *PaymentRepository) FindByID(id uint) (*entities.Payment, error) {
	var payment entities.Payment
	err := r.DB.Preload("Bill").Preload("Tenant").First(&payment, id).Error
	if err != nil {
		return nil, err
	}
	return &payment, nil
}

// FindByBillID finds a payment by bill ID
func (r *PaymentRepository) FindByBillID(billID uint) (*entities.Payment, error) {
	var payment entities.Payment
	err := r.DB.Where("bill_id = ?", billID).
		Preload("Bill").Preload("Tenant").
		First(&payment).Error
	if err != nil {
		return nil, err
	}
	return &payment, nil
}

// List returns paginated list of payments for an owner
func (r *PaymentRepository) List(ownerID uint, page, limit int) ([]entities.Payment, int64, error) {
	var payments []entities.Payment
	var total int64

	offset := (page - 1) * limit

	// Build query with joins through bills → tenants → rooms → buildings
	query := r.DB.Model(&entities.Payment{}).
		Joins("JOIN bills ON bills.id = payments.bill_id").
		Joins("JOIN tenants ON tenants.id = bills.tenant_id").
		Joins("JOIN rooms ON rooms.id = tenants.room_id").
		Joins("JOIN buildings ON buildings.id = rooms.building_id").
		Where("buildings.owner_id = ?", ownerID)

	// Count total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := query.
		Preload("Bill").Preload("Tenant").
		Order("payments.paid_at DESC").
		Offset(offset).Limit(limit).
		Find(&payments).Error

	if err != nil {
		return nil, 0, err
	}

	return payments, total, nil
}

// ListByTenant returns payments for a specific tenant
func (r *PaymentRepository) ListByTenant(tenantID uint, page, limit int) ([]entities.Payment, int64, error) {
	var payments []entities.Payment
	var total int64

	offset := (page - 1) * limit

	// Count total
	if err := r.DB.Model(&entities.Payment{}).Where("tenant_id = ?", tenantID).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Get paginated results
	err := r.DB.Where("tenant_id = ?", tenantID).
		Preload("Bill").
		Order("paid_at DESC").
		Offset(offset).Limit(limit).
		Find(&payments).Error

	if err != nil {
		return nil, 0, err
	}

	return payments, total, nil
}
