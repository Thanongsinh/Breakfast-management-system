import { DefaultSession } from 'next-auth';
import { Role } from './auth.types';

declare module 'next-auth' {
  interface Session {
    user: {
      id: number;
      email: string;
      name: string;
      role: Role;
      phoneNumber?: string;
      createdAt: string;
      updatedAt: string;
    };
    accessToken: string;
  }

  interface JWT {
    accessToken?: string;
    role?: Role;
    phoneNumber?: string;
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    accessToken?: string;
    role?: Role;
    phoneNumber?: string;
  }
}
