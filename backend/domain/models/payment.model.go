package models

import "time"

type ConfirmCashPaymentRequest struct {
	BillID uint    `json:"bill_id" validate:"required"`
	Amount float64 `json:"amount" validate:"required"`
	Note   string  `json:"note"`
}

type PaymentResponse struct {
	ID             uint      `json:"id"`
	BillID         uint      `json:"bill_id"`
	TenantID       uint      `json:"tenant_id"`
	TenantName     string    `json:"tenant_name"`
	Amount         float64   `json:"amount"`
	PaidAt         time.Time `json:"paid_at"`
	ConfirmedBy    uint      `json:"confirmed_by"`
	ConfirmedByName string   `json:"confirmed_by_name"`
	ReceiptPDFPath string    `json:"receipt_pdf_path"`
	Note           string    `json:"note"`
}
