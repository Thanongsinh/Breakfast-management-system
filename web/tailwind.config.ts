import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        owner: {
          DEFAULT: '#2563EB',
          light: '#3B82F6',
          dark: '#1D4ED8',
        },
        admin: {
          DEFAULT: '#4F46E5',
          light: '#6366F1',
          dark: '#4338CA',
        },
        tenant: {
          DEFAULT: '#7C3AED',
          light: '#8B5CF6',
          dark: '#6D28D9',
        },
        status: {
          paid: '#10B981',
          unpaid: '#EF4444',
          pending: '#F59E0B',
          overdue: '#DC2626',
          available: '#10B981',
          occupied: '#3B82F6',
          maintenance: '#F59E0B',
        },
      },
    },
  },
  plugins: [],
};

export default config;
