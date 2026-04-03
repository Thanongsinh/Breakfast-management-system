package utilities

import (
	"gorm.io/gorm"
	"rental-backend/domain/models"
)

// ParsePaginationParams parses pagination parameters from request
func ParsePaginationParams(page, limit int) models.PaginationRequest {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	return models.PaginationRequest{
		Page:  page,
		Limit: limit,
	}
}

// ApplyPagination applies pagination to GORM query
func ApplyPagination(db *gorm.DB, pagination models.PaginationRequest) *gorm.DB {
	offset := (pagination.Page - 1) * pagination.Limit
	return db.Offset(offset).Limit(pagination.Limit)
}

// BuildPaginationResponse builds pagination response
func BuildPaginationResponse(page, limit int, totalItems int64) models.PaginationResponse {
	totalPages := int(totalItems) / limit
	if int(totalItems)%limit > 0 {
		totalPages++
	}

	return models.PaginationResponse{
		Page:       page,
		Limit:      limit,
		TotalItems: totalItems,
		TotalPages: totalPages,
	}
}
