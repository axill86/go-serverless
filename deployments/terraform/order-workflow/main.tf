resource "aws_sfn_state_machine" "order-workflow" {
  definition = templatefile("${path.module}/workflow.tmpl",
  { "generate_configurations_lambda" : var.generate-configurations-lambda })
  name       = var.workflow-name
  role_arn   = aws_iam_role.order-workflow-role.arn
}

## Execution role for sfn lambda
resource "aws_iam_role" "order-workflow-role" {
  name = "${var.workflow-name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.order-workflow-policy.json
}
## Inline policy for invoke underlying lambda
resource "aws_iam_role_policy" "workflow-inline-policy" {
  role = aws_iam_role.order-workflow-role.name
  name = "${var.workflow-name}-policy"
  policy = data.aws_iam_policy_document.workflow-policy-document.json
}

data "aws_iam_policy_document" "workflow-policy-document" {
  statement {
    actions = ["lambda:InvokeFunction"]
    effect = "Allow"
    resources = [var.generate-configurations-lambda]
  }
}
data "aws_iam_policy_document" "order-workflow-policy" {
  #Allows Lambda to assume execution Role
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}