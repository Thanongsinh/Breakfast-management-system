export type PaymentMethod = 'cash' | 'promptpay' | 'bank_transfer';
export type PaymentStatus = 'pending' | 'confirmed' | 'rejected';

export interface Payment {
  id: number;
  billId: number;
  amount: number;
  method: PaymentMethod;
  status: PaymentStatus;
  slipUrl?: string;
  confirmedBy?: number;
  confirmedAt?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
  bill?: {
    id: number;
    roomNumber: string;
    buildingName: string;
    tenantName?: string;
    dueDate: string;
  };
}

export interface ConfirmCashPaymentRequest {
  billId: number;
  amount: number;
  paidDate: string;
  note?: string;
}

export interface PaymentFilters {
  status?: PaymentStatus;
  method?: PaymentMethod;
  buildingId?: number;
  page?: number;
  limit?: number;
}

export interface PaymentReceipt {
  id: number;
  billId: number;
  amount: number;
  method: PaymentMethod;
  paidAt: string;
  receiptNumber: string;
  tenantName: string;
  roomNumber: string;
  buildingName: string;
}
