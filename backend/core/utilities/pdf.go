package utilities

import (
	"fmt"
	"os"
	"path/filepath"
	"rental-v3/backend/domain/entities"
	"time"

	"github.com/jung-kurt/gofpdf"
)

// GenerateReceiptPDF generates a payment receipt PDF
func GenerateReceiptPDF(payment entities.Payment, bill entities.Bill, tenant entities.Tenant, tenantUser entities.User, room entities.Room) (string, error) {
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font for Thai text support (using default fonts for now)
	pdf.SetFont("Arial", "B", 20)

	// Header
	pdf.CellFormat(0, 10, "PAYMENT RECEIPT", "", 1, "C", false, 0, "")
	pdf.Ln(5)

	// Receipt number and date
	pdf.SetFont("Arial", "", 12)
	receiptNo := fmt.Sprintf("RCPT-%d-%d", payment.ID, time.Now().Unix())
	pdf.CellFormat(0, 8, fmt.Sprintf("Receipt No: %s", receiptNo), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Date: %s", payment.PaidAt.Format("2006-01-02 15:04:05")), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Tenant information
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Tenant Information", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, fmt.Sprintf("Name: %s", tenantUser.Name), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Email: %s", tenantUser.Email), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Phone: %s", tenantUser.Phone), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Room: %s", room.Number), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Bill details
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Bill Details", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, fmt.Sprintf("Period: %02d/%d", bill.Month, bill.Year), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Rent Amount: %.2f THB", bill.RentAmount), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Water: %.2f units x %.2f = %.2f THB", bill.WaterUnit, bill.WaterPrice/bill.WaterUnit, bill.WaterPrice), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Electric: %.2f units x %.2f = %.2f THB", bill.ElectricUnit, bill.ElectricPrice/bill.ElectricUnit, bill.ElectricPrice), "", 1, "", false, 0, "")
	if bill.OtherFees > 0 {
		pdf.CellFormat(0, 8, fmt.Sprintf("Other Fees: %.2f THB (%s)", bill.OtherFees, bill.OtherFeesNote), "", 1, "", false, 0, "")
	}
	pdf.Ln(3)

	// Total
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 10, fmt.Sprintf("Total Amount: %.2f THB", bill.Total), "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 10, fmt.Sprintf("Amount Paid: %.2f THB", payment.Amount), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Note
	if payment.Note != "" {
		pdf.SetFont("Arial", "I", 10)
		pdf.CellFormat(0, 8, fmt.Sprintf("Note: %s", payment.Note), "", 1, "", false, 0, "")
		pdf.Ln(3)
	}

	// Footer
	pdf.Ln(10)
	pdf.SetFont("Arial", "I", 10)
	pdf.CellFormat(0, 8, "Thank you for your payment!", "", 1, "C", false, 0, "")
	pdf.CellFormat(0, 8, "This is a computer-generated receipt.", "", 1, "C", false, 0, "")

	// Create temp directory if it doesn't exist
	tempDir := filepath.Join(os.TempDir(), "rental-receipts")
	os.MkdirAll(tempDir, 0755)

	// Save PDF to temp file
	filename := fmt.Sprintf("receipt_%d_%d.pdf", payment.ID, time.Now().Unix())
	filepath := filepath.Join(tempDir, filename)

	err := pdf.OutputFileAndClose(filepath)
	if err != nil {
		return "", err
	}

	return filepath, nil
}

// GenerateContractPDF generates a rental contract PDF
func GenerateContractPDF(contract entities.Contract, tenant entities.Tenant, tenantUser entities.User, room entities.Room, building entities.Building) (string, error) {
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	// Set font
	pdf.SetFont("Arial", "B", 20)

	// Header
	pdf.CellFormat(0, 10, "RENTAL AGREEMENT", "", 1, "C", false, 0, "")
	pdf.Ln(5)

	// Contract number and date
	pdf.SetFont("Arial", "", 12)
	contractNo := fmt.Sprintf("CONTRACT-%d", contract.ID)
	pdf.CellFormat(0, 8, fmt.Sprintf("Contract No: %s", contractNo), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Date: %s", contract.CreatedAt.Format("2006-01-02")), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Property information
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Property Information", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, fmt.Sprintf("Building: %s", building.Name), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Address: %s", building.Address), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Room Number: %s", room.Number), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Floor: %d", room.Floor), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Room Type: %s", room.Type), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Size: %.2f sqm", room.SizeSqm), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Tenant information
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Tenant Information", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, fmt.Sprintf("Name: %s", tenantUser.Name), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Email: %s", tenantUser.Email), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Phone: %s", tenantUser.Phone), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("ID Card: %s", tenant.IDCardNumber), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Emergency Contact: %s", tenant.EmergencyContact), "", 1, "", false, 0, "")
	pdf.Ln(5)

	// Contract terms
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Contract Terms", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, fmt.Sprintf("Start Date: %s", contract.StartDate.Format("2006-01-02")), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("End Date: %s", contract.EndDate.Format("2006-01-02")), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Monthly Rent: %.2f THB", contract.RentAmount), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 8, fmt.Sprintf("Security Deposit: %.2f THB", contract.Deposit), "", 1, "", false, 0, "")
	pdf.Ln(10)

	// Terms and conditions
	pdf.SetFont("Arial", "B", 12)
	pdf.CellFormat(0, 8, "Terms and Conditions:", "", 1, "", false, 0, "")
	pdf.SetFont("Arial", "", 11)
	pdf.MultiCell(0, 6, "1. The tenant agrees to pay rent on or before the 5th of each month.\n"+
		"2. Utilities (water and electricity) will be charged separately based on actual usage.\n"+
		"3. The security deposit will be refunded upon termination of the contract, subject to room inspection.\n"+
		"4. The tenant must maintain the room in good condition.\n"+
		"5. The tenant must not sublet the room without written permission from the owner.\n"+
		"6. This contract may be terminated with 30 days written notice from either party.", "", "", false)

	pdf.Ln(15)

	// Signature section
	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(90, 8, "____________________________", "", 0, "C", false, 0, "")
	pdf.CellFormat(90, 8, "____________________________", "", 1, "C", false, 0, "")
	pdf.CellFormat(90, 8, "Owner Signature", "", 0, "C", false, 0, "")
	pdf.CellFormat(90, 8, "Tenant Signature", "", 1, "C", false, 0, "")

	// Create temp directory if it doesn't exist
	tempDir := filepath.Join(os.TempDir(), "rental-contracts")
	os.MkdirAll(tempDir, 0755)

	// Save PDF to temp file
	filename := fmt.Sprintf("contract_%d_%d.pdf", contract.ID, time.Now().Unix())
	filepath := filepath.Join(tempDir, filename)

	err := pdf.OutputFileAndClose(filepath)
	if err != nil {
		return "", err
	}

	return filepath, nil
}
