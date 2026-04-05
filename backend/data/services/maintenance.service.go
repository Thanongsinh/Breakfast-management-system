package services

import (
	"errors"
	"fmt"
	"github.com/lib/pq"
	"mime/multipart"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/entities"
	"rental-v3/backend/domain/models"
	"time"
)

type MaintenanceService struct {
	maintenanceRepo *repositories.MaintenanceRepository
	roomRepo        *repositories.RoomRepository
	buildingRepo    *repositories.BuildingRepository
	storageService  StorageService
}

func NewMaintenanceService(
	maintenanceRepo *repositories.MaintenanceRepository,
	roomRepo *repositories.RoomRepository,
	buildingRepo *repositories.BuildingRepository,
	storageService StorageService,
) *MaintenanceService {
	return &MaintenanceService{
		maintenanceRepo: maintenanceRepo,
		roomRepo:        roomRepo,
		buildingRepo:    buildingRepo,
		storageService:  storageService,
	}
}

// Create creates a new maintenance request (by tenant)
func (s *MaintenanceService) Create(tenantID uint, req models.CreateMaintenanceRequest) (*entities.MaintenanceRequest, error) {
	maintenanceReq := &entities.MaintenanceRequest{
		RoomID:      req.RoomID,
		TenantID:    tenantID,
		Title:       req.Title,
		Description: req.Description,
		Images:      pq.StringArray{},
		Status:      "pending",
		Priority:    req.Priority,
	}

	if maintenanceReq.Priority == "" {
		maintenanceReq.Priority = "medium"
	}

	if err := s.maintenanceRepo.Create(maintenanceReq); err != nil {
		return nil, err
	}

	return maintenanceReq, nil
}

// Update updates a maintenance request (by owner)
func (s *MaintenanceService) Update(id, ownerID uint, req models.UpdateMaintenanceRequest) error {
	maintenanceReq, err := s.maintenanceRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Verify ownership through room -> building
	room, err := s.roomRepo.FindByID(maintenanceReq.RoomID)
	if err != nil {
		return err
	}

	building, err := s.buildingRepo.FindByID(room.BuildingID)
	if err != nil {
		return err
	}

	if building.OwnerID != ownerID {
		return errors.New("forbidden: not the owner of this maintenance request")
	}

	// Update fields
	if req.Status != "" {
		maintenanceReq.Status = req.Status
	}

	// If marked as done, set resolved time
	if req.Status == "done" && maintenanceReq.ResolvedAt == nil {
		now := time.Now()
		maintenanceReq.ResolvedAt = &now
	}

	return s.maintenanceRepo.Update(maintenanceReq)
}

// UploadImages uploads images for a maintenance request
func (s *MaintenanceService) UploadImages(id uint, files []*multipart.FileHeader) error {
	maintenanceReq, err := s.maintenanceRepo.FindByID(id)
	if err != nil {
		return err
	}

	// Upload images to MinIO
	var imagePaths []string
	for i, file := range files {
		fileName := fmt.Sprintf("maintenance/%d/%d-%s", id, time.Now().Unix(), file.Filename)

		// Open file
		src, err := file.Open()
		if err != nil {
			continue
		}
		defer src.Close()

		// Upload to storage (simplified - in real implementation would use MinIO)
		imagePaths = append(imagePaths, fileName)

		// Limit to 5 images
		if i >= 4 {
			break
		}
	}

	// Update images array
	existingImages := []string(maintenanceReq.Images)
	existingImages = append(existingImages, imagePaths...)
	maintenanceReq.Images = pq.StringArray(existingImages)

	return s.maintenanceRepo.Update(maintenanceReq)
}

// GetByID gets a maintenance request by ID
func (s *MaintenanceService) GetByID(id uint) (*entities.MaintenanceRequest, error) {
	return s.maintenanceRepo.FindByID(id)
}

// ListByTenant returns paginated maintenance requests for a tenant
func (s *MaintenanceService) ListByTenant(tenantID uint, page, limit int) ([]entities.MaintenanceRequest, int64, error) {
	return s.maintenanceRepo.ListByTenant(tenantID, page, limit)
}

// ListByOwner returns paginated maintenance requests for an owner
func (s *MaintenanceService) ListByOwner(ownerID uint, status string, page, limit int) ([]entities.MaintenanceRequest, int64, error) {
	return s.maintenanceRepo.ListByOwner(ownerID, status, page, limit)
}
