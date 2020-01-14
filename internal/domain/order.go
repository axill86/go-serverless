package domain

type Status string

const (
	CREATED   Status = "CREATED"
	FAILED    Status = "FAILED"
	COMPLETED Status = "COMPLETED"
)

type Order struct {
	Id       string `json:"id"`
	Status   Status `json:"status"`
	ResultId string `json:"resultId,omitempty"`
	Type     string `json:"type,omitempty"`
}
