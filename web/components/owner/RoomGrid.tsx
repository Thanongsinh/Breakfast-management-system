'use client';

import { cn } from '@/lib/utils';
import { formatCurrency } from '@/lib/utils';
import type { Room } from '@/types/building.types';

interface RoomGridProps {
  rooms: Room[];
  onRoomClick?: (room: Room) => void;
}

const statusColors = {
  available: 'bg-status-available text-white',
  occupied: 'bg-status-occupied text-white',
  maintenance: 'bg-status-maintenance text-white',
};

export function RoomGrid({ rooms, onRoomClick }: RoomGridProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {rooms.map((room) => (
        <div
          key={room.id}
          onClick={() => onRoomClick?.(room)}
          className={cn(
            'rounded-lg shadow-md p-4 cursor-pointer transition-transform hover:scale-105',
            statusColors[room.status]
          )}
        >
          <div className="flex justify-between items-start mb-2">
            <h3 className="text-lg font-bold">{room.roomNumber}</h3>
            <span className="text-xs px-2 py-1 bg-white bg-opacity-30 rounded">
              Floor {room.floor}
            </span>
          </div>

          <div className="mt-3 space-y-1 text-sm">
            <p className="font-semibold">{formatCurrency(room.monthlyRent)}/month</p>
            {room.currentTenantName && (
              <p className="text-xs opacity-90">Tenant: {room.currentTenantName}</p>
            )}
          </div>

          <div className="mt-3 pt-3 border-t border-white border-opacity-30 text-xs">
            <div className="flex justify-between">
              <span>Water:</span>
              <span>{formatCurrency(room.waterPricePerUnit)}/unit</span>
            </div>
            <div className="flex justify-between mt-1">
              <span>Electric:</span>
              <span>{formatCurrency(room.electricityPricePerUnit)}/unit</span>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
