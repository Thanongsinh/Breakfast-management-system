package bootstrap

import (
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
	// TODO: implement full config loading with Viper
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	var config Config
	// Placeholder implementation
	return &config, nil
}
