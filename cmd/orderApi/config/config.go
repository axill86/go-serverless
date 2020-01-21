package config

//Config stores the configuration needed for
type Config struct {
	//DynamoDb Table which stores calculation
	TableName string `mapstructure:"table"`
	//Workflow name to execute
	Workflow string `mapstructure: "workflow"`
}
