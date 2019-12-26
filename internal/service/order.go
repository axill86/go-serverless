package service

import (
	"github.com/axill86/go-serverless/internal/dao"
	"github.com/axill86/go-serverless/internal/domain"
)

/*
Order service provides operations related to orders
*/
type OrderService interface {
	CreateOrder() (domain.Order, error)
}

type orderServiceImp struct {
	dao dao.OrderDao
}

//CreateOrder creates new order and places it for execution.
//Returns created order instance
func (service *orderServiceImp) CreateOrder() (domain.Order, error) {
	return service.dao.CreateOrder()
}

func NewOrderService(orderDao dao.OrderDao) *orderServiceImp {
	return &orderServiceImp{dao: orderDao}
}
