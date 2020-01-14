package dao

//go:generate mockgen -destination=../../mocks/dao/$GOFILE -source $GOFILE
import (
	"errors"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/axill86/go-serverless/internal/domain"
	"github.com/axill86/go-serverless/internal/dto"
	"github.com/google/uuid"
)

type OrderDao interface {
	GetOrder(id string) (domain.Order, error)
	CreateOrder(dto dto.OrderCreate) (domain.Order, error)
	UpdateOrder(order domain.Order) error
}

/*
	Mock for now (return constant)
*/
type dynamoDbOrderDao struct {
	TableName string
	DynamoDb  *dynamodb.DynamoDB
}

func NewOrderDao(tableName string, dynamo *dynamodb.DynamoDB) *dynamoDbOrderDao {
	return &dynamoDbOrderDao{TableName: tableName, DynamoDb: dynamo}
}

func (dao *dynamoDbOrderDao) GetOrder(id string) (domain.Order, error) {
	item, err := dao.DynamoDb.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(dao.TableName),
		Key: map[string]*dynamodb.AttributeValue{
			"id": {
				S: aws.String(id),
			},
		},
	})
	if err != nil {
		return domain.Order{}, err
	}
	result := domain.Order{}
	err = dynamodbattribute.UnmarshalMap(item.Item, &result)
	if err != nil {
		return domain.Order{}, err
	}
	return result, nil
}

func (dao *dynamoDbOrderDao) CreateOrder(orderDto dto.OrderCreate) (domain.Order, error) {
	id := uuid.New().String()
	order := domain.Order{Id: id, Status: domain.CREATED, Type:orderDto.Type}
	attributes, err := dynamodbattribute.MarshalMap(order)
	if err != nil {
		return order, err
	}
	itemInput := dynamodb.PutItemInput{TableName: aws.String(dao.TableName), Item: attributes}
	_, err = dao.DynamoDb.PutItem(&itemInput)
	if err != nil {
		return order, err
	}
	return order, nil
}

func (dao *dynamoDbOrderDao) UpdateOrder(order domain.Order) error {
	return errors.New("not supported yet")
}
