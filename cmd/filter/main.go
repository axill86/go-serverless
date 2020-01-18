package main

import (
	"context"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/axill86/go-serverless/internal/dto"
)

func main() {
	lambda.Start(FilterHandler)
}
func FilterHandler(ctx context.Context, items []dto.Item) ([]dto.Item, error) {
	var res []dto.Item
	for _, item := range items {
		if item.Passed {
			res = append(res, item)
		}
	}
	return res, nil
}
