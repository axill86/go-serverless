package service

//go:generate mockgen -destination=$PWD/mocks -package mocks github.com/axill86/go-serverless/internal/domain OrderDao
import (
	"github.com/axill86/go-serverless/internal/domain"
	"github.com/axill86/go-serverless/internal/dto"
	"github.com/axill86/go-serverless/internal/service"
	mock_dao "github.com/axill86/go-serverless/mocks/dao"
	"github.com/golang/mock/gomock"
	"testing"
)

func TestCreateOrder(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	dao := mock_dao.NewMockOrderDao(ctrl)
	service := service.NewOrderService(dao)
	dao.EXPECT().CreateOrder(dto.OrderCreate{Type: "single"}).Return(domain.Order{Status: domain.CREATED, Id: "1"}, nil).Times(1)
	order, err := service.CreateOrder(dto.OrderCreate{Type: "single"})
	if order.Id != "1" && err != nil {
		t.Errorf("Result does not match")
	}
}

func TestGetOrder(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	dao := mock_dao.NewMockOrderDao(ctrl)
	service := service.NewOrderService(dao)
	dao.EXPECT().GetOrder("1").Return(domain.Order{Status: domain.CREATED, Id: "1"}, nil).Times(1)
	order, err := service.GetOrder("1")
	if order.Id != "1" && err != nil {
		t.Errorf("Result does not match")
	}
}
