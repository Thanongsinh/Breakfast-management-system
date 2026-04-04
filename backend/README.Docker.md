# Docker Deployment Guide

## Quick Start

### 1. Build and Run with Docker Compose

```bash
# Start all services (PostgreSQL, Redis, MinIO, Backend)
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop all services
docker-compose down

# Stop and remove volumes (cleans all data)
docker-compose down -v
```

### 2. Build Docker Image Only

```bash
# Build the backend image
docker build -t rental-backend:latest .

# Run the backend container manually
docker run -d \
  -p 8080:8080 \
  -e DATABASE_HOST=localhost \
  -e DATABASE_PASSWORD=postgres \
  -e JWT_SECRET=your-secret-key \
  --name rental-backend \
  rental-backend:latest
```

## Services Included

### 1. PostgreSQL Database
- **Port**: 5432
- **User**: postgres
- **Password**: postgres
- **Database**: rental_db
- **Volume**: `postgres_data`

### 2. Redis Cache
- **Port**: 6379
- **Password**: (none)
- **Volume**: `redis_data`

### 3. MinIO Object Storage
- **Port**: 9000 (API), 9001 (Console)
- **User**: minioadmin
- **Password**: minioadmin
- **Console**: http://localhost:9001
- **Volume**: `minio_data`

### 4. Backend API
- **Port**: 8080
- **Health Check**: http://localhost:8080/health
- **API Base**: http://localhost:8080/api

## Environment Variables

You can customize the deployment by modifying the `docker-compose.yml` file or using a `.env` file:

```env
# Database
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=your-secure-password
DATABASE_NAME=rental_db
DATABASE_SSLMODE=disable

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password
REDIS_DB=0

# MinIO
MINIO_ENDPOINT=minio:9000
MINIO_ACCESSKEY=your-minio-access-key
MINIO_SECRETKEY=your-minio-secret-key
MINIO_USE_SSL=false

# JWT
JWT_SECRET=your-super-secret-jwt-key-min-32-characters
JWT_ACCESS_EXPIRE_HOURS=24
JWT_REFRESH_EXPIRE_DAYS=30

# LINE Notify (optional)
LINE_NOTIFYTOKEN=your-line-notify-token

# Server
SERVER_ENV=production
SERVER_PORT=8080
```

## Useful Commands

```bash
# Check service status
docker-compose ps

# View logs for specific service
docker-compose logs -f postgres
docker-compose logs -f redis
docker-compose logs -f minio
docker-compose logs -f backend

# Restart a specific service
docker-compose restart backend

# Execute command in backend container
docker-compose exec backend sh

# Access PostgreSQL database
docker-compose exec postgres psql -U postgres -d rental_db

# Access Redis CLI
docker-compose exec redis redis-cli

# View backend resource usage
docker stats rental-backend
```

## Production Deployment

### Security Checklist

1. **Change default passwords** in `docker-compose.yml`:
   - PostgreSQL password
   - Redis password (if needed)
   - MinIO access/secret keys
   - JWT secret (use strong random string)

2. **Use secrets management** (Docker Swarm or Kubernetes):
   ```bash
   # Example with Docker secrets
   echo "your-strong-password" | docker secret create db_password -
   ```

3. **Enable SSL/TLS**:
   - Set `DATABASE_SSLMODE=require`
   - Set `MINIO_USE_SSL=true`
   - Use a reverse proxy (nginx/traefik) with SSL certificates

4. **Network security**:
   - Don't expose database ports publicly (remove `ports:` from postgres/redis/minio)
   - Use internal Docker network only
   - Add firewall rules

5. **Resource limits**:
   ```yaml
   backend:
     deploy:
       resources:
         limits:
           cpus: '1.0'
           memory: 512M
         reservations:
           cpus: '0.5'
           memory: 256M
   ```

### Health Checks

All services have health checks configured:
- **PostgreSQL**: `pg_isready` command
- **Redis**: `redis-cli ping`
- **MinIO**: HTTP endpoint check
- **Backend**: Waits for all dependencies

### Backup & Recovery

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U postgres rental_db > backup.sql

# Restore PostgreSQL
docker-compose exec -T postgres psql -U postgres rental_db < backup.sql

# Backup volumes
docker run --rm -v rental-v3_postgres_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres_backup.tar.gz /data
```

## Monitoring

### Access MinIO Console
http://localhost:9001
- Username: minioadmin
- Password: minioadmin

### Check Backend Health
```bash
curl http://localhost:8080/health
```

### View Database Tables
```bash
docker-compose exec postgres psql -U postgres -d rental_db -c "\dt"
```

## Troubleshooting

### Backend can't connect to database
```bash
# Check if PostgreSQL is ready
docker-compose exec postgres pg_isready

# Check backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend
```

### Port already in use
```bash
# Check which process is using port 8080
netstat -ano | findstr :8080

# Change port in docker-compose.yml
ports:
  - "8081:8080"  # Use 8081 instead
```

### Clear all data and restart
```bash
# Stop and remove everything
docker-compose down -v

# Rebuild and start fresh
docker-compose up -d --build
```
