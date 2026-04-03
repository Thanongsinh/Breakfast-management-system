export type BillStatus = 'unpaid' | 'paid' | 'pending' | 'overdue';

export interface Bill {
  id: number;
  roomId: number;
  roomNumber: string;
  buildingName: string;
  tenantName?: string;
  amount: number;
  waterUnit: number;
  electricityUnit: number;
  waterCost: number;
  electricityCost: number;
  status: BillStatus;
  dueDate: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface GenerateBillsRequest {
  month: number;
  year: number;
}

export interface BillFilters {
  status?: BillStatus;
  buildingId?: number;
  month?: number;
  year?: number;
  page?: number;
  limit?: number;
}
