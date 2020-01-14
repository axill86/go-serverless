package service

import (
	"github.com/axill86/go-serverless/internal/dao"
	"github.com/axill86/go-serverless/internal/domain"
	"github.com/axill86/go-serverless/internal/dto"
)

/*
OrderCreate service provides operations related to orders
*/
type OrderService interface {
	CreateOrder(dto dto.OrderCreate) (domain.Order, error)
	GetOrder(id string) (domain.Order, error)
}

type orderServiceImp struct {
	dao dao.OrderDao
}

//CreateOrder creates new order and places it for execution.
//Returns created order instance
func (service *orderServiceImp) CreateOrder(dto dto.OrderCreate) (domain.Order, error) {
	return service.dao.CreateOrder(dto)
}

func (service *orderServiceImp) GetOrder(id string) (domain.Order, error) {
	return service.dao.GetOrder(id)
}

func NewOrderService(orderDao dao.OrderDao) *orderServiceImp {
	return &orderServiceImp{dao: orderDao}
}
