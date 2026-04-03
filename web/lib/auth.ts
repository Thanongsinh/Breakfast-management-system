import NextAuth from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';
import type { User } from '@/types/auth.types';

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }

        try {
          const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: credentials.email,
              password: credentials.password,
            }),
          });

          const data = await res.json();

          if (res.ok && data.success) {
            return {
              id: data.data.user.id.toString(),
              email: data.data.user.email,
              name: data.data.user.name,
              role: data.data.user.role,
              phoneNumber: data.data.user.phoneNumber,
              accessToken: data.data.access_token,
            };
          }
          return null;
        } catch (error) {
          console.error('Login error:', error);
          return null;
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        // Store access token and user data in JWT
        token.accessToken = (user as any).accessToken;
        token.role = (user as any).role;
        token.phoneNumber = (user as any).phoneNumber;
      }
      return token;
    },
    async session({ session, token }) {
      // Add access token and custom fields to session
      return {
        ...session,
        accessToken: token.accessToken as string,
        user: {
          id: parseInt(token.sub || '0'),
          email: token.email || '',
          name: token.name || '',
          role: token.role as any,
          phoneNumber: token.phoneNumber as string,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      };
    },
  },
  pages: {
    signIn: '/login',
  },
  session: {
    strategy: 'jwt',
  },
});
