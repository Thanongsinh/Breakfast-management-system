export type MaintenanceStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled';
export type MaintenancePriority = 'low' | 'medium' | 'high' | 'urgent';

export interface MaintenanceRequest {
  id: number;
  roomId: number;
  roomNumber: string;
  buildingName: string;
  tenantId?: number;
  tenantName?: string;
  title: string;
  description: string;
  priority: MaintenancePriority;
  status: MaintenanceStatus;
  reportedAt: string;
  scheduledAt?: string;
  completedAt?: string;
  assignedTo?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateMaintenanceRequest {
  roomId: number;
  title: string;
  description: string;
  priority: MaintenancePriority;
}

export interface UpdateMaintenanceRequest {
  status?: MaintenanceStatus;
  scheduledAt?: string;
  assignedTo?: string;
  notes?: string;
}

export interface MaintenanceFilters {
  status?: MaintenanceStatus;
  priority?: MaintenancePriority;
  buildingId?: number;
  page?: number;
  limit?: number;
}
