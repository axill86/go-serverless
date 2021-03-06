package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/sfn"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/axill86/go-serverless/cmd/orderApi/config"
	"github.com/axill86/go-serverless/internal/dto"
	"github.com/spf13/viper"
	"log"

	"github.com/axill86/go-serverless/internal/dao"
	"github.com/axill86/go-serverless/internal/service"
	"github.com/gin-contrib/location"
	"github.com/gin-gonic/gin"
	"net/http"
)

var orderService service.OrderService
var r *gin.Engine
var ginLambda *ginadapter.GinLambda

func init() {
	//read config
	c, err := readConfig()
	if err != nil {
		panic(err)
	}
	r := gin.Default()
	//Init order service
	r.Use(location.Default())
	r.POST("/orders", CreateOrderHandler)
	r.GET("/orders", GetOrderHandler)
	s, err := session.NewSession()
	if err != nil {
		panic(err)
	}
	dynamoSession := dynamodb.New(s)
	workflowSession := sfn.New(s)
	workflowService := service.NewWorkflowService(workflowSession, c.Workflow)
	orderService = service.NewOrderService(dao.NewOrderDao(c.TableName, dynamoSession), workflowService)
	ginLambda = ginadapter.New(r)
}

//reads configuration for Lambda
func readConfig() (*config.Config, error) {

	v := viper.New()
	v.SetEnvPrefix("order")
	v.AutomaticEnv()
	c := &config.Config{TableName: v.GetString("table"), Workflow: v.GetString("workflow")}
	log.Printf("Received config %#v", c)
	return c, nil
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}
func main() {
	lambda.Start(Handler)
}

func CreateOrderHandler(context *gin.Context) {
	var dto dto.OrderCreate
	if err := context.ShouldBindJSON(&dto); err != nil {
		context.AbortWithStatusJSON(http.StatusBadRequest, err.Error())
	}
	order, err := orderService.CreateOrder(dto)
	if err != nil {
		context.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	fmt.Printf("Received headers %#v", context.Request.Header)
	fmt.Printf("Created order %#v", order)
	context.Status(http.StatusCreated)
	context.Header("Location", "orders?id="+order.Id)
}

func GetOrderHandler(context *gin.Context) {
	id := context.Query("id")
	order, err := orderService.GetOrder(id)
	if err != nil {
		context.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	log.Printf("Got order %#v", order)
	context.JSON(http.StatusOK, order)
}
