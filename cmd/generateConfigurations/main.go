//That lambda supposed to generate json with configurations which are going to be used for further processing
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"math/rand"
)

type Event struct {
	Type string `json:"type"`
}

type Item struct {
	Name string `json:"name"`
	Quantity int32 `json:"quantity"`
}

//HandleRequest generates random number of items (up to 10) for given event
func HandleRequest (ctx context.Context, event Event) ([]Item, error) {
	max := rand.Intn(10 + 1)
	var result []Item
	for i := 0; i<max; i++ {
		item := Item{Name:fmt.Sprintf("%s_%d", event.Type, i), Quantity:rand.Int31()}
		result = append(result, item)
	}
	return result, nil
}
func main() {
	lambda.Start(HandleRequest)
}