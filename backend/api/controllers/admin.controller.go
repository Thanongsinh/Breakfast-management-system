package controllers

import (
	"rental-v3/backend/core/utilities"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/data/services"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
	"time"

	"github.com/gofiber/fiber/v2"
)

// AdminController handles admin-related requests
type AdminController struct {
	paymentService *services.PaymentService
	paymentRepo    *repositories.PaymentRepository
	userRepo       *repositories.UserRepository
	buildingRepo   *repositories.BuildingRepository
	roomRepo       *repositories.RoomRepository
	billRepo       *repositories.BillRepository
}

// NewAdminController creates a new instance of AdminController
func NewAdminController(
	paymentService *services.PaymentService,
	paymentRepo *repositories.PaymentRepository,
	userRepo *repositories.UserRepository,
	buildingRepo *repositories.BuildingRepository,
	roomRepo *repositories.RoomRepository,
	billRepo *repositories.BillRepository,
) *AdminController {
	return &AdminController{
		paymentService: paymentService,
		paymentRepo:    paymentRepo,
		userRepo:       userRepo,
		buildingRepo:   buildingRepo,
		roomRepo:       roomRepo,
		billRepo:       billRepo,
	}
}

// GetDashboard returns admin dashboard data with system-wide statistics
func (ctrl *AdminController) GetDashboard(c *fiber.Ctx) error {
	// Extract userID from JWT claims (set by AuthMiddleware)
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Get total owners count
	totalOwners := int64(0)
	if err := ctrl.userRepo.DB.Model(&entities.User{}).Where("role = ?", "owner").Count(&totalOwners).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count owners")
	}

	// Get total buildings count
	totalBuildings := int64(0)
	if err := ctrl.buildingRepo.DB.Model(&entities.Building{}).Count(&totalBuildings).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count buildings")
	}

	// Get total rooms count
	totalRooms := int64(0)
	if err := ctrl.roomRepo.DB.Model(&entities.Room{}).Where("deleted_at IS NULL").Count(&totalRooms).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count rooms")
	}

	// Get occupied rooms count
	occupiedRooms := int64(0)
	if err := ctrl.roomRepo.DB.Model(&entities.Room{}).Where("status = ? AND deleted_at IS NULL", "occupied").Count(&occupiedRooms).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count occupied rooms")
	}

	// Get pending payments count and total amount
	pendingPayments := int64(0)
	var totalPendingAmount float64
	if err := ctrl.billRepo.DB.Model(&entities.Bill{}).
		Where("status IN (?)", []string{"unpaid", "overdue"}).
		Count(&pendingPayments).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count pending payments")
	}

	// Get total pending amount
	type Result struct {
		Sum float64
	}
	var result Result
	if err := ctrl.billRepo.DB.Model(&entities.Bill{}).
		Select("COALESCE(SUM(total), 0) as sum").
		Where("status IN (?)", []string{"unpaid", "overdue"}).
		Scan(&result).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to calculate pending amount")
	}
	totalPendingAmount = result.Sum

	// Calculate Monthly Recurring Revenue (MRR) from occupied rooms
	var mrrResult Result
	if err := ctrl.roomRepo.DB.Model(&entities.Room{}).
		Select("COALESCE(SUM(rent_price), 0) as sum").
		Where("status = ? AND deleted_at IS NULL", "occupied").
		Scan(&mrrResult).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to calculate MRR")
	}

	// Build response
	response := models.AdminDashboardResponse{
		TotalOwners:        int(totalOwners),
		TotalBuildings:     int(totalBuildings),
		TotalRooms:         int(totalRooms),
		OccupiedRooms:      int(occupiedRooms),
		PendingPayments:    int(pendingPayments),
		TotalPendingAmount: totalPendingAmount,
		MonthlyMRR:         mrrResult.Sum,
	}

	return utilities.SuccessResponse(c, response)
}

// ListAllPayments retrieves all payments across the entire system with pagination
func (ctrl *AdminController) ListAllPayments(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)
	offset := (page - 1) * limit

	// Get all payments with pagination
	var payments []struct {
		ID              uint
		BillID          uint
		TenantID        uint
		Amount          float64
		PaidAt          time.Time
		ConfirmedBy     uint
		ReceiptPDFPath  string
		Note            string
		TenantName      string
		ConfirmedByName string
	}
	var total int64

	// Count total
	if err := ctrl.paymentRepo.DB.Model(&entities.Payment{}).Count(&total).Error; err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to count payments")
	}

	// Get paginated results with joins
	err := ctrl.paymentRepo.DB.
		Table("payments").
		Select("payments.*, tenants.name as tenant_name, users.name as confirmed_by_name").
		Joins("LEFT JOIN tenants ON tenants.id = payments.tenant_id").
		Joins("LEFT JOIN users ON users.id = payments.confirmed_by").
		Order("payments.paid_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&payments).Error

	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to retrieve payments")
	}

	// Build response list
	paymentResponses := make([]models.PaymentResponse, len(payments))
	for i, payment := range payments {
		paymentResponses[i] = models.PaymentResponse{
			ID:              payment.ID,
			BillID:          payment.BillID,
			TenantID:        payment.TenantID,
			TenantName:      payment.TenantName,
			Amount:          payment.Amount,
			PaidAt:          payment.PaidAt,
			ConfirmedBy:     payment.ConfirmedBy,
			ConfirmedByName: payment.ConfirmedByName,
			ReceiptPDFPath:  payment.ReceiptPDFPath,
			Note:            payment.Note,
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, paymentResponses, pagination)
}

// ListOwners retrieves all owners with pagination
func (ctrl *AdminController) ListOwners(c *fiber.Ctx) error {
	// Extract userID from JWT claims
	_, ok := c.Locals("userID").(uint)
	if !ok {
		return utilities.ErrorResponse(c, fiber.StatusUnauthorized, "Unauthorized")
	}

	// Parse pagination params
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 20)
	offset := (page - 1) * limit

	// Call repository to get owners by role
	owners, total, err := ctrl.userRepo.ListByRole("owner", limit, offset)
	if err != nil {
		return utilities.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to retrieve owners")
	}

	// Build response list (excluding sensitive data like password hash)
	type OwnerResponse struct {
		ID         uint   `json:"id"`
		Name       string `json:"name"`
		Email      string `json:"email"`
		Phone      string `json:"phone"`
		LineUserID string `json:"line_user_id"`
		CreatedAt  string `json:"created_at"`
	}

	ownerResponses := make([]OwnerResponse, len(owners))
	for i, owner := range owners {
		ownerResponses[i] = OwnerResponse{
			ID:         owner.ID,
			Name:       owner.Name,
			Email:      owner.Email,
			Phone:      owner.Phone,
			LineUserID: owner.LineUserID,
			CreatedAt:  owner.CreatedAt.Format("2006-01-02 15:04:05"),
		}
	}

	// Build pagination
	pagination := utilities.BuildPaginationResponse(page, limit, total)

	return utilities.PaginatedResponse(c, ownerResponses, pagination)
}
