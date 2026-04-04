# Database Seeder - Default Users

## Overview

This seeder creates default test users for each role in the Rental Management System.

## Default Users

### 👤 Admin User
- **Email**: `admin@rental.com`
- **Password**: `admin123`
- **Role**: Admin
- **Phone**: 081-234-5678
- **Purpose**: System administration and payment management

### 🏠 Owner User
- **Email**: `owner@rental.com`
- **Password**: `owner123`
- **Role**: Owner
- **Phone**: 082-345-6789
- **Purpose**: Manage buildings, rooms, tenants, and bills

### 🏢 Tenant User
- **Email**: `tenant@rental.com`
- **Password**: `tenant123`
- **Role**: Tenant
- **Phone**: 083-456-7890
- **Purpose**: View bills, make payments, submit maintenance requests

## Usage

### Option 1: Windows Batch Script (Recommended)
```bash
cd backend
seed.bat
```

### Option 2: Manual Execution
```bash
cd backend
go run seed_users.go
```

### Option 3: Build and Run
```bash
cd backend
go build -o seed_users seed_users.go
./seed_users
```

## Features

✅ **Idempotent** - Can be run multiple times safely
- If users already exist, they will be updated with new passwords
- If users don't exist, they will be created

✅ **Secure** - All passwords are hashed using bcrypt

✅ **Safe** - Checks for existing users before creating

## When to Use

Run the seeder when you need to:
1. **Initial Setup** - First time setting up the database
2. **Testing** - Need fresh test users with known credentials
3. **Reset Passwords** - Forgot password for test users
4. **Development** - Reset database and need default users again

## Database Requirements

Make sure you have:
1. PostgreSQL running (via Docker or local installation)
2. `.env` file with correct database credentials
3. Database migrations already run (tables created)

## Troubleshooting

### Error: "Failed to load config"
- Check if `.env` file exists in the backend directory
- Verify database credentials in `.env`

### Error: "Failed to connect to database"
- Ensure PostgreSQL is running
- Check database connection details in `config.yaml` and `.env`
- Verify the database exists: `rental_db`

### Error: "Failed to create/update user"
- Check if the database migrations have run
- Verify the `users` table exists
- Check database user permissions

## After Seeding

You can now login to the application using any of the default credentials:

### Web (http://localhost:3000)
- Login as admin, owner, or tenant
- Each role has different dashboard and permissions

### Mobile App
- Login with the same credentials
- Switch between owner and tenant accounts

## Security Note

⚠️ **IMPORTANT**: These are **test/development credentials only**!

For production:
1. Create real users through the admin panel
2. Use strong, unique passwords
3. Enable two-factor authentication
4. Change or delete these default accounts

## Resetting Users

To reset users to default state:
```bash
# Method 1: Run seeder again (updates existing users)
cd backend
seed.bat

# Method 2: Delete users and recreate
# Via database:
DELETE FROM users WHERE email IN ('admin@rental.com', 'owner@rental.com', 'tenant@rental.com');
# Then run seeder
```

## Integration with Docker

The seeder can also be run inside Docker:
```bash
# Method 1: Docker exec
docker-compose exec backend go run seed_users.go

# Method 2: Add to docker-compose
# Add a seed service in docker-compose.yml:
services:
  seed:
    build: .
    command: go run seed_users.go
    depends_on:
      postgres:
        condition: service_healthy
```

## Custom Users

To create additional custom users, you can:

1. **Modify seed_users.go**:
   - Add more users to the `users` slice
   - Rebuild and run

2. **Use the API**:
   ```bash
   POST http://localhost:8080/api/auth/register
   {
     "email": "custom@rental.com",
     "password": "password123",
     "name": "Custom User",
     "role": "owner"
   }
   ```

3. **Direct SQL** (not recommended):
   ```sql
   -- Don't forget to hash the password!
   INSERT INTO users (name, email, password_hash, role, phone)
   VALUES ('Custom User', 'custom@rental.com', '$2a$10$...', 'owner', '084-567-8901');
   ```
