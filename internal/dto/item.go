package dto

type Item struct {
	Name     string `json:"name"`
	Quantity int32  `json:"quantity"`
	Passed   bool   `json:"passed,omitempty"`
}
