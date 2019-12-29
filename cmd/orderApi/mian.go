package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
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

	orderService = service.NewOrderService(dao.NewOrderDao("orders", dynamoSession))
	ginLambda = ginadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}
func main() {
	lambda.Start(Handler)
}

func CreateOrderHandler(context *gin.Context) {
	order, err := orderService.CreateOrder()
	if err != nil {
		context.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	fmt.Printf("Created order %#v", order)
	context.Status(http.StatusCreated)
	context.Header("Location", "orders/"+order.Id)
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
