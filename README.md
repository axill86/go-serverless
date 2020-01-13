# Go Serverless
This is the demo project for serverless application written in GO =)
Idea is to build an application which triggers workflow of several steps.
This project follows [Golang Project Layout](https://raw.githubusercontent.com/golang-standards/project-layout)

# Project layout
* **cmd** all the command handlers put there
* **cmd/orderApi** implementation of lambda, which handles creation of order
* **deployments** deployments are done via [terraform](https://www.terraform.io/)
* **internal** internal packages, which can be used across different handlers
* **mocks** generated mocks
* **scripts** various bash scripts
* **test** handler tests
* **dist** folder is used for placing deployable artifacts (like lambda zip files)

# Usage
## Prerequisites
* [docker](https://www.docker.com/) & [terraform](https://www.terraform.io/) need to be installed
* AWS account access need to be configured

## How to deploy
In order to deploy following command need to be run
``make dist deploy``
Terraform will ask for confirmation for creating required AWS resources. Type 'yes' to proceed
URL of deployed api is provided in tf output
``
https://api-url.execute-api.us-east-1.amazonaws.com/test/orders
``

## How to test
Public endpoint is created on Amazon Api Gateway. In order to create order POST request need to be executed:
``` curl -v -X POST https://api-url.execute-api.us-east-1.amazonaws.com/test/orders ```
Expected that **CREATED(201)** is returned with Location header:
```location: orders?id=<uuid> ```
TODO: unfortunately, full path is not returned so far. 
Created resource can be requested via url
``` curl "https://api-url.execute-api.us-east-1.amazonaws.com/test/orders?id=<uuid>"```
## How to destroy
``make destroy``
Terraform will ask for confirmation. Type 'yes' to destroy



