export type ContractStatus = 'active' | 'expired' | 'terminated';

export interface Tenant {
  id: number;
  name: string;
  email: string;
  phoneNumber: string;
  idCard: string;
  currentRoomId?: number;
  currentRoomNumber?: string;
  currentBuildingName?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Contract {
  id: number;
  tenantId: number;
  roomId: number;
  startDate: string;
  endDate: string;
  monthlyRent: number;
  deposit: number;
  status: ContractStatus;
  terminatedAt?: string;
  terminationReason?: string;
  createdAt: string;
  updatedAt: string;
  tenant?: Tenant;
  room?: {
    id: number;
    roomNumber: string;
    buildingName: string;
  };
}

export interface CreateTenantRequest {
  name: string;
  email: string;
  phoneNumber: string;
  idCard: string;
}

export interface UpdateTenantRequest {
  name?: string;
  email?: string;
  phoneNumber?: string;
  idCard?: string;
}

export interface CreateContractRequest {
  tenantId: number;
  roomId: number;
  startDate: string;
  endDate: string;
  monthlyRent: number;
  deposit: number;
}

export interface TerminateContractRequest {
  reason: string;
}
