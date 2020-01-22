package service

//go:generate mockgen -destination=../../mocks/service/$GOFILE -source $GOFILE

import (
	"encoding/json"
	"github.com/aws/aws-sdk-go/service/sfn"
)

type WorkflowService interface {
	SubmitTask(id string, itemType string) error
}

func NewWorkflowService(sfn *sfn.SFN, workflowArn string) *workflowServiceImpl {
	return &workflowServiceImpl{sfn: sfn, workflowArn: workflowArn}
}

type workflowServiceImpl struct {
	sfn         *sfn.SFN
	workflowArn string
}

type workflowInput struct {
	Type string `json:"type"`
	Id   string `json:"id"`
}

func (service *workflowServiceImpl) SubmitTask(id string, itemType string) error {
	json, err := json.Marshal(workflowInput{Id: id, Type: itemType})
	if err != nil {
		return err
	}
	input := string(json)
	_, err = service.sfn.StartExecution(&sfn.StartExecutionInput{StateMachineArn: &service.workflowArn, Name: &id, Input: &input})
	if err != nil {
		return err
	}
	return nil
}
