package main

import (
	"fmt"
	"github.com/axill86/go-serverless/internal/dao"
	"github.com/axill86/go-serverless/internal/service"
	"github.com/gin-contrib/location"
	"github.com/gin-gonic/gin"
	"net/http"
)

var orderService service.OrderService

func init() {
	orderService = service.NewOrderService(dao.NewOrderDao())
}

func main() {
	r := gin.Default()
	r.Use(location.Default())
	r.POST("/orders", CreateOrderHandler)
	r.GET("/orders", GetOrderHandler)
	r.Run(":80")
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
	fmt.Printf("Got order %#v", order)
	context.JSON(http.StatusOK, order)
}
