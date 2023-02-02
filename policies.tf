locals {
  log_group_name = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : "/aws/lambda/${var.lambda_name}"

  logging_policy = var.lambda_logging_policy != null ? var.lambda_logging_policy : {
    name        = "tf-lambda-logging-to-${var.lambda_name}"
    path        = var.cloudwatch_log_group_path
    description = var.cloudwatch_log_group_description != null ? var.cloudwatch_log_group_description : "IAM policy for logging from a lambda ${var.lambda_name}"
    policy = {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:${local.log_group_name}*:*",
          "Effect" : "Allow"
        }
      ]
    }
  }

  policies = concat([local.logging_policy], var.custom_policies != null ? var.custom_policies : [])

  tags_iam_role_default = {
    "Name"        = var.lambda_name
    "tf-iam-role" = var.lambda_name
    "tf-ou"       = var.ou_name
  }

  tags_cloudwatch_log_group_default = {
    "Name"                    = var.lambda_name
    "tf-cloudwatch-log-group" = var.lambda_name
    "tf-ou"                   = var.ou_name
  }
}

resource "aws_iam_role" "create_iam_for_lambda" {
  count = var.lambda_role_arn == null ? 1 : 0

  name               = "${var.lambda_name}-trust-role"
  assume_role_policy = jsonencode(var.lambda_assume_role)
  description        = "Required main role to lambda function"
  tags               = merge(var.tags_iam_role, var.use_tags_default ? local.tags_iam_role_default : {})
}

resource "aws_iam_policy" "create_policies" {
  count = length(local.policies)

  name        = local.policies[count.index].name
  path        = local.policies[count.index].path
  description = local.policies[count.index].description
  policy      = jsonencode(local.policies[count.index].policy)
}

resource "aws_iam_role_policy_attachment" "create_attachments" {
  count = length(local.policies)

  role       = try(aws_iam_role.create_iam_for_lambda[0].name, var.lambda_role_arn)
  policy_arn = aws_iam_policy.create_policies[count.index].arn
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  count = var.subnet_ids != null ? 1 : 0

  role       = try(aws_iam_role.create_iam_for_lambda[0].name, var.lambda_role_arn)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
