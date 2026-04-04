package bootstrap

import (
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	MinIO    MinIOConfig
	JWT      JWTConfig
	LINE     LINEConfig
	Billing  BillingConfig
	Cron     CronConfig
}

type ServerConfig struct {
	Port string
	Env  string
}

type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
	SSLMode  string
}

type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

type MinIOConfig struct {
	Endpoint  string
	AccessKey string `mapstructure:"access_key"`
	SecretKey string `mapstructure:"secret_key"`
	UseSSL    bool   `mapstructure:"use_ssl"`
	Buckets   struct {
		Receipts    string
		Contracts   string
		Maintenance string
	}
}

type JWTConfig struct {
	Secret           string
	AccessExpireHrs  int `mapstructure:"access_expire_hours"`
	RefreshExpireDays int `mapstructure:"refresh_expire_days"`
}

type LINEConfig struct {
	NotifyToken string `mapstructure:"notify_token"`
}

type BillingConfig struct {
	WaterRatePerUnit    float64 `mapstructure:"water_rate_per_unit"`
	ElectricRatePerUnit float64 `mapstructure:"electric_rate_per_unit"`
	DueDay              int     `mapstructure:"due_day"`
}

type CronConfig struct {
	BillGenerate  string `mapstructure:"bill_generate"`
	ReminderFirst string `mapstructure:"reminder_first"`
	ReminderFinal string `mapstructure:"reminder_final"`
}

// LoadConfig loads configuration from config.yaml and ENV variables
func LoadConfig() (*Config, error) {
	// Set config file
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("./")

	// Read config file
	if err := viper.ReadInConfig(); err != nil {
		return nil, err
	}

	// Enable automatic env variable override
	viper.AutomaticEnv()

	// Replace dots with underscores for ENV variables
	// e.g., database.password -> DATABASE_PASSWORD
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// Bind specific ENV variables that override config.yaml
	viper.BindEnv("database.name", "DATABASE_NAME")
	viper.BindEnv("database.password", "DATABASE_PASSWORD")
	viper.BindEnv("redis.password", "REDIS_PASSWORD")
	viper.BindEnv("minio.access_key", "MINIO_ACCESSKEY")
	viper.BindEnv("minio.secret_key", "MINIO_SECRETKEY")
	viper.BindEnv("jwt.secret", "JWT_SECRET")
	viper.BindEnv("line.notify_token", "LINE_NOTIFYTOKEN")

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, err
	}

	return &config, nil
}
