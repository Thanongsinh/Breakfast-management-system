export type Role = 'owner' | 'admin' | 'tenant';

export interface User {
  id: number;
  email: string;
  name: string;
  role: Role;
  phoneNumber?: string;
  createdAt: string;
  updatedAt: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: User;
}

export interface Session {
  user: User;
  accessToken: string;
  expires: string;
}
