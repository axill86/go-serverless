package main

import (
	"context"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/axill86/go-serverless/internal/dto"
)

func main() {
	lambda.Start(Handler)
}

//Handler returns result, which is true if quantity is even
func Handler(ctxt context.Context, e dto.Item) (dto.Item, error) {
	return dto.Item{Name: e.Name, Quantity: e.Quantity, Passed: e.Quantity%2 == 0}, nil
}
