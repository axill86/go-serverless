package dao

import (
	"errors"
	"github.com/axill86/go-serverless/internal/domain"
	"github.com/google/uuid"
)

type OrderDao interface {
	GetOrder(id string) (domain.Order, error)
	CreateOrder() (domain.Order, error)
	UpdateOrder(order domain.Order) error
}

/*
	Mock for now (return constant)
*/
type staticOrderDao struct {
}

func NewOrderDao() *staticOrderDao {
	return &staticOrderDao{}
}

func (dao *staticOrderDao) GetOrder(id string) (domain.Order, error) {
	return domain.Order{}, errors.New("not implemented yet")
}

func (dao *staticOrderDao) CreateOrder() (domain.Order, error) {
	id := uuid.New()
	return domain.Order{Id: id.String(), Status: domain.CREATED}, nil
}

func (dao *staticOrderDao) UpdateOrder(order domain.Order) error {
	return errors.New("not supported yet")
}
