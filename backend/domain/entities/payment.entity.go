package entities

import "time"

type Payment struct {
	ID             uint      `gorm:"primaryKey"`
	BillID         uint      `gorm:"not null;index"`
	TenantID       uint      `gorm:"not null;index"`
	Amount         float64   `gorm:"not null"` // จำนวนเงินที่รับจริง
	PaidAt         time.Time `gorm:"not null"`
	ConfirmedBy    uint      `gorm:"not null"` // owner หรือ admin user_id
	ReceiptPDFPath string
	Note           string    // หมายเหตุ เช่น "จ่ายแบ่ง 2 ครั้ง"
	CreatedAt      time.Time
}
