export type RoomStatus = 'available' | 'occupied' | 'maintenance';

export interface Room {
  id: number;
  buildingId: number;
  roomNumber: string;
  floor: number;
  monthlyRent: number;
  waterPricePerUnit: number;
  electricityPricePerUnit: number;
  status: RoomStatus;
  currentTenantId?: number;
  currentTenantName?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Building {
  id: number;
  ownerId: number;
  name: string;
  address: string;
  totalRooms: number;
  occupiedRooms: number;
  availableRooms: number;
  maintenanceRooms: number;
  createdAt: string;
  updatedAt: string;
  rooms?: Room[];
}

export interface CreateBuildingRequest {
  name: string;
  address: string;
}

export interface UpdateBuildingRequest {
  name?: string;
  address?: string;
}

export interface CreateRoomRequest {
  buildingId: number;
  roomNumber: string;
  floor: number;
  monthlyRent: number;
  waterPricePerUnit: number;
  electricityPricePerUnit: number;
}

export interface UpdateRoomRequest {
  roomNumber?: string;
  floor?: number;
  monthlyRent?: number;
  waterPricePerUnit?: number;
  electricityPricePerUnit?: number;
  status?: RoomStatus;
}
