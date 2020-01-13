resource "aws_sfn_state_machine" "order-workflow" {
  definition = templatefile("${path.module}/workflow.tmpl", {})
  name       = var.workflow-name
  role_arn   = aws_iam_role.order-workflow-role.arn
}

## Execution role for sfn lambda
resource "aws_iam_role" "order-workflow-role" {
  name = "${var.workflow-name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.order-workflow-policy.json
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