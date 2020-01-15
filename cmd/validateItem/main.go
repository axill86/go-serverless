package main

import "context"

type item struct {
	Name     string `json:"name"`
	Quantity int32  `json:"quantity"`
}
type result struct {
	item
	Passed bool
}

func main() {

}

//Handler returns result, which is true if quantity is even
func Handler(ctxt context.Context, e item) (result, error) {
	return result{item{Name: e.Name, Quantity: e.Quantity}, e.Quantity%2 == 0}, nil
}
