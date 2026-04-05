package main

import (
	"log"
	"os"
	"rental-v3/backend/api/routes"
	"rental-v3/backend/bootstrap"
	"rental-v3/backend/data/repositories"
	"rental-v3/backend/data/services"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Load configuration
	config, err := bootstrap.LoadConfig()
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// Initialize database
	db, err := bootstrap.InitDB(config)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	log.Println("✓ Database connected successfully")

	// Initialize all repositories
	userRepo := repositories.NewUserRepository(db)
	buildingRepo := repositories.NewBuildingRepository(db)
	roomRepo := repositories.NewRoomRepository(db)
	tenantRepo := repositories.NewTenantRepository(db)
	contractRepo := repositories.NewContractRepository(db)
	billRepo := repositories.NewBillRepository(db)
	paymentRepo := repositories.NewPaymentRepository(db)
	maintenanceRepo := repositories.NewMaintenanceRepository(db)

	// Initialize all services
	authService := services.NewAuthService(userRepo, config)
	buildingService := services.NewBuildingService(buildingRepo)
	storageService := services.NewStorageService()
	roomService := services.NewRoomService(roomRepo, buildingRepo)
	tenantService := services.NewTenantService(tenantRepo, roomRepo, buildingRepo)
	contractService := services.NewContractService(contractRepo, tenantRepo, roomRepo, buildingRepo, storageService)
	billService := services.NewBillService(billRepo, tenantRepo, contractRepo, config)
	notificationService := services.NewNotificationService(config)
	paymentService := services.NewPaymentService(paymentRepo, billRepo, tenantRepo, storageService, notificationService)
	maintenanceService := services.NewMaintenanceService(maintenanceRepo, roomRepo, buildingRepo, storageService)
	reportService := services.NewReportService(billRepo, paymentRepo)

	log.Println("✓ Services initialized successfully")

	// Create Fiber app
	app := fiber.New(fiber.Config{
		AppName:      "Rental Management System v3",
		ServerHeader: "Fiber",
		ErrorHandler: customErrorHandler,
	})

	// Global middleware
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${status} - ${method} ${path} (${latency})\n",
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,DELETE,PATCH,OPTIONS",
		AllowHeaders: "Origin,Content-Type,Accept,Authorization",
	}))

	// Health check endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
			"message": "Rental Management System v3 is running",
		})
	})

	// Setup routes with dependency injection
	routes.SetupAuthRoutes(app, authService, userRepo, config.JWT.Secret)
	routes.SetupOwnerRoutes(app, buildingService, roomService, tenantService, contractService, billService, paymentService, maintenanceService, reportService, config.JWT.Secret)
	routes.SetupTenantRoutes(app, billService, paymentService, maintenanceService, contractService, config.JWT.Secret)
	routes.SetupAdminRoutes(app, paymentService, notificationService, userRepo, paymentRepo, buildingRepo, roomRepo, billRepo, config.JWT.Secret)

	log.Println("✓ Routes configured successfully")

	// Get port from configuration or environment
	port := config.Server.Port
	if port == "" {
		port = os.Getenv("PORT")
		if port == "" {
			port = "8080"
		}
	}

	// Start server
	log.Printf("🚀 Server starting on port %s...", port)
	log.Printf("📍 API Base URL: http://localhost:%s/api", port)
	log.Printf("")
	log.Printf("🔐 Auth endpoints:")
	log.Printf("   POST   /api/auth/login")
	log.Printf("   POST   /api/auth/refresh")
	log.Printf("   GET    /api/auth/me (protected)")
	log.Printf("   POST   /api/auth/logout (protected)")
	log.Printf("")
	log.Printf("🏢 Owner endpoints: /api/owner/* (auth + role:owner required)")
	log.Printf("🏠 Tenant endpoints: /api/tenant/* (auth + role:tenant required)")
	log.Printf("⚙️  Admin endpoints: /api/admin/* (auth + role:admin required)")
	log.Printf("")
	log.Printf("✅ All 11 controllers implemented and ready!")

	if err := app.Listen(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

// customErrorHandler handles errors globally
func customErrorHandler(c *fiber.Ctx, err error) error {
	// Default to 500 Internal Server Error
	code := fiber.StatusInternalServerError

	// Check if it's a fiber error
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}

	// Log the error
	log.Printf("Error: %v", err)

	// Return error response
	return c.Status(code).JSON(fiber.Map{
		"success": false,
		"error":   err.Error(),
		"code":    code,
	})
}
