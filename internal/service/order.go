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
	dao             dao.OrderDao
	workflowService WorkflowService
}

//CreateOrder creates new order and places it for execution.
//Returns created order instance
func (service *orderServiceImp) CreateOrder(dto dto.OrderCreate) (domain.Order, error) {
	order, err := service.dao.CreateOrder(dto)
	if err != nil {
		return domain.Order{}, err
	}
	err = service.workflowService.SubmitTask(order.Id, order.Type)
	if err != nil {
		return domain.Order{}, err
	}
	return order, nil
}

func (service *orderServiceImp) GetOrder(id string) (domain.Order, error) {
	return service.dao.GetOrder(id)
}

func NewOrderService(orderDao dao.OrderDao, service WorkflowService) *orderServiceImp {
	return &orderServiceImp{dao: orderDao, workflowService: service}
}
