package service

import (
	"github.com/axill86/go-serverless/internal/domain"
	"github.com/axill86/go-serverless/internal/dto"
	"github.com/axill86/go-serverless/internal/service"
	mock_dao "github.com/axill86/go-serverless/mocks/dao"
	mock_service "github.com/axill86/go-serverless/mocks/service"
	"github.com/golang/mock/gomock"
	"testing"
)

const (
	orderId   = "1"
	orderType = "single"
)

func TestCreateOrder(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	dao := mock_dao.NewMockOrderDao(ctrl)
	workflowService := mock_service.NewMockWorkflowService(ctrl)
	service := service.NewOrderService(dao, workflowService)
	dao.EXPECT().CreateOrder(dto.OrderCreate{Type: orderType}).Return(domain.Order{Status: domain.CREATED, Id: orderId, Type: orderType}, nil).Times(1)
	workflowService.EXPECT().SubmitTask(orderId, orderType).Return(nil).Times(1)
	order, err := service.CreateOrder(dto.OrderCreate{Type: orderType})
	if order.Id != orderId && err != nil {
		t.Errorf("Result does not match")
	}
}

func TestGetOrder(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	dao := mock_dao.NewMockOrderDao(ctrl)
	workflowService := mock_service.NewMockWorkflowService(ctrl)
	service := service.NewOrderService(dao, workflowService)
	dao.EXPECT().GetOrder("1").Return(domain.Order{Status: domain.CREATED, Id: "1"}, nil).Times(1)
	order, err := service.GetOrder("1")
	if order.Id != "1" && err != nil {
		t.Errorf("Result does not match")
	}
}
