package services

import (
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/domain/models"
	"time"
)

type ReportService struct {
	billRepo    *repositories.BillRepository
	paymentRepo *repositories.PaymentRepository
}

func NewReportService(
	billRepo *repositories.BillRepository,
	paymentRepo *repositories.PaymentRepository,
) *ReportService {
	return &ReportService{
		billRepo:    billRepo,
		paymentRepo: paymentRepo,
	}
}

// GenerateIncomeReport generates an income report for a specific month/year
func (s *ReportService) GenerateIncomeReport(ownerID uint, month, year int) (*models.IncomeReportResponse, error) {
	// Get all bills for the month
	filters := map[string]interface{}{
		"month": month,
		"year":  year,
	}
	bills, _, err := s.billRepo.ListByOwner(ownerID, filters, 1, 1000)
	if err != nil {
		return nil, err
	}

	var totalIncome float64
	var totalBills int
	var paidBills int
	var unpaidBills int
	var paymentDetails []models.PaymentResponse

	totalBills = len(bills)

	for _, bill := range bills {
		if bill.Status == "paid" {
			paidBills++
			totalIncome += bill.Total

			// Get payment details
			payment, err := s.paymentRepo.FindByBillID(bill.ID)
			if err == nil {
				paymentDetails = append(paymentDetails, models.PaymentResponse{
					ID:             payment.ID,
					BillID:         payment.BillID,
					TenantID:       payment.TenantID,
					Amount:         payment.Amount,
					PaidAt:         payment.PaidAt,
					ConfirmedBy:    payment.ConfirmedBy,
					ReceiptPDFPath: payment.ReceiptPDFPath,
					Note:           payment.Note,
				})
			}
		} else {
			unpaidBills++
		}
	}

	return &models.IncomeReportResponse{
		Month:          month,
		Year:           year,
		TotalIncome:    totalIncome,
		TotalBills:     totalBills,
		PaidBills:      paidBills,
		UnpaidBills:    unpaidBills,
		PaymentDetails: paymentDetails,
	}, nil
}

// GenerateUnpaidReport generates a report of all unpaid bills grouped by tenant
func (s *ReportService) GenerateUnpaidReport(ownerID uint) ([]models.UnpaidReportResponse, error) {
	// Get all unpaid bills
	bills, err := s.billRepo.ListUnpaid(ownerID)
	if err != nil {
		return nil, err
	}

	// Group by tenant
	tenantMap := make(map[uint]*models.UnpaidReportResponse)

	for _, bill := range bills {
		if _, exists := tenantMap[bill.TenantID]; !exists {
			tenantMap[bill.TenantID] = &models.UnpaidReportResponse{
				TenantID:    bill.TenantID,
				TotalUnpaid: 0,
				UnpaidBills: []models.BillResponse{},
				OverdueDays: 0,
			}
		}

		tenantMap[bill.TenantID].TotalUnpaid += bill.Total
		tenantMap[bill.TenantID].UnpaidBills = append(tenantMap[bill.TenantID].UnpaidBills, models.BillResponse{
			ID:            bill.ID,
			TenantID:      bill.TenantID,
			RoomID:        bill.RoomID,
			Month:         bill.Month,
			Year:          bill.Year,
			RentAmount:    bill.RentAmount,
			WaterUnit:     bill.WaterUnit,
			WaterPrice:    bill.WaterPrice,
			ElectricUnit:  bill.ElectricUnit,
			ElectricPrice: bill.ElectricPrice,
			OtherFees:     bill.OtherFees,
			OtherFeesNote: bill.OtherFeesNote,
			Total:         bill.Total,
			DueDate:       bill.DueDate,
			Status:        bill.Status,
		})

		// Calculate overdue days from the oldest bill
		overdueDays := int(time.Since(bill.DueDate).Hours() / 24)
		if overdueDays > tenantMap[bill.TenantID].OverdueDays {
			tenantMap[bill.TenantID].OverdueDays = overdueDays
		}
	}

	// Convert map to slice
	var result []models.UnpaidReportResponse
	for _, report := range tenantMap {
		result = append(result, *report)
	}

	return result, nil
}

// ExportToExcel exports income report to Excel (simplified version)
func (s *ReportService) ExportToExcel(ownerID uint, month, year int) (string, error) {
	// In a real implementation, this would use the excel utility to generate an Excel file
	// For now, we'll return a placeholder
	return "reports/income-report.xlsx", nil
}
