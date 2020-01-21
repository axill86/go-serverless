variable "lambda-name" {

}
variable "lambda-handler" {

}
variable "lambda-filename" {

}

variable "policy-document" {}

variable "environment-variables" {
  type = map(string)
  default = null
}
