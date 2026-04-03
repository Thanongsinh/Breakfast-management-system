package services

import (
	"context"
	"time"
)

// IncomeReport represents income report data
type IncomeReport struct {
	TotalIncome    float64
	PaidIncome     float64
	UnpaidIncome   float64
	Month          time.Time
	BuildingBreakdown map[string]float64
}

// UnpaidReport represents unpaid bills report data
type UnpaidReport struct {
	TotalUnpaid   float64
	UnpaidCount   int
	Bills         []UnpaidBillItem
}

// UnpaidBillItem represents individual unpaid bill
type UnpaidBillItem struct {
	BillID       string
	TenantName   string
	RoomNumber   string
	Amount       float64
	DueDate      time.Time
}

// ReportService defines methods for report generation
type ReportService interface {
	GenerateIncomeReport(ctx context.Context, ownerID string, startDate, endDate time.Time) (*IncomeReport, error)
	GenerateUnpaidReport(ctx context.Context, ownerID string) (*UnpaidReport, error)
	ExportToExcel(ctx context.Context, reportData interface{}) ([]byte, error)
}

// reportServiceImpl is the concrete implementation of ReportService
type reportServiceImpl struct {
	// TODO: add dependencies (bill repository, payment repository)
}

// NewReportService creates a new instance of ReportService
func NewReportService() ReportService {
	return &reportServiceImpl{}
}

func (s *reportServiceImpl) GenerateIncomeReport(ctx context.Context, ownerID string, startDate, endDate time.Time) (*IncomeReport, error) {
	// TODO: implement
	return nil, nil
}

func (s *reportServiceImpl) GenerateUnpaidReport(ctx context.Context, ownerID string) (*UnpaidReport, error) {
	// TODO: implement
	return nil, nil
}

func (s *reportServiceImpl) ExportToExcel(ctx context.Context, reportData interface{}) ([]byte, error) {
	// TODO: implement
	return nil, nil
}
