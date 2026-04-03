'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { formatCurrency } from '@/lib/utils';
import type { MRRData } from '@/services/admin/stats.service';

interface MRRChartProps {
  data: MRRData[];
}

export function MRRChart({ data }: MRRChartProps) {
  return (
    <div className="h-80 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="month" />
          <YAxis tickFormatter={(value) => formatCurrency(value)} />
          <Tooltip
            formatter={(value: number) => formatCurrency(value)}
            contentStyle={{ backgroundColor: 'white', border: '1px solid #ccc' }}
          />
          <Legend />
          <Line
            type="monotone"
            dataKey="mrr"
            stroke="#4F46E5"
            strokeWidth={2}
            name="Monthly Recurring Revenue"
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
