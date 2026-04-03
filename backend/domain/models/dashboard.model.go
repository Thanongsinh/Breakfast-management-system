package models

type OwnerDashboardResponse struct {
	TotalBuildings     int     `json:"total_buildings"`
	TotalRooms         int     `json:"total_rooms"`
	OccupiedRooms      int     `json:"occupied_rooms"`
	AvailableRooms     int     `json:"available_rooms"`
	UnpaidBills        int     `json:"unpaid_bills"`
	TotalUnpaidAmount  float64 `json:"total_unpaid_amount"`
	MonthlyRevenue     float64 `json:"monthly_revenue"`
	PendingMaintenance int     `json:"pending_maintenance"`
}

type TenantDashboardResponse struct {
	RoomNumber         string  `json:"room_number"`
	BuildingName       string  `json:"building_name"`
	MonthlyRent        float64 `json:"monthly_rent"`
	CurrentBill        *BillResponse `json:"current_bill"`
	UnpaidBillsCount   int     `json:"unpaid_bills_count"`
	LastPayment        *PaymentResponse `json:"last_payment"`
	ContractEndDate    string  `json:"contract_end_date"`
}

type AdminDashboardResponse struct {
	TotalOwners        int     `json:"total_owners"`
	TotalBuildings     int     `json:"total_buildings"`
	TotalRooms         int     `json:"total_rooms"`
	OccupiedRooms      int     `json:"occupied_rooms"`
	PendingPayments    int     `json:"pending_payments"`
	TotalPendingAmount float64 `json:"total_pending_amount"`
	MonthlyMRR         float64 `json:"monthly_mrr"`
}
