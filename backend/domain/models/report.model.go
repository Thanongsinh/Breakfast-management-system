package models

import "time"

type IncomeReportResponse struct {
	Month         int     `json:"month"`
	Year          int     `json:"year"`
	TotalIncome   float64 `json:"total_income"`
	TotalBills    int     `json:"total_bills"`
	PaidBills     int     `json:"paid_bills"`
	UnpaidBills   int     `json:"unpaid_bills"`
	PaymentDetails []PaymentResponse `json:"payment_details"`
}

type UnpaidReportResponse struct {
	TenantID       uint      `json:"tenant_id"`
	TenantName     string    `json:"tenant_name"`
	RoomNumber     string    `json:"room_number"`
	TotalUnpaid    float64   `json:"total_unpaid"`
	UnpaidBills    []BillResponse `json:"unpaid_bills"`
	OverdueDays    int       `json:"overdue_days"`
	LastContactAt  *time.Time `json:"last_contact_at"`
}
