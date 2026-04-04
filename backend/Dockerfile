# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o rental-backend .

# Runtime stage
FROM alpine:latest

WORKDIR /root/

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates tzdata

# Copy the binary from builder
COPY --from=builder /app/rental-backend .

# Copy config files
COPY --from=builder /app/config.yaml .
COPY --from=builder /app/config.docker.yaml .

# Expose port
EXPOSE 8080

# Run the application with docker config
CMD ["./rental-backend"]
