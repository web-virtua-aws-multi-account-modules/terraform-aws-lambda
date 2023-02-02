output "lambda_function" {
  description = "Lambda function"
  value       = aws_lambda_function.create_lambda_function
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.create_lambda_function.arn
}

output "lambda_function_role" {
  description = "Lambda function role"
  value       = aws_lambda_function.create_lambda_function.role
}

output "lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.create_lambda_function.invoke_arn
}

output "lambda_function_invoke_memory_size" {
  description = "Lambda function memory size"
  value       = aws_lambda_function.create_lambda_function.memory_size
}

output "lambda_function_invoke_runtime" {
  description = "Lambda function runtime"
  value       = aws_lambda_function.create_lambda_function.runtime
}

output "lambda_layers" {
  description = "Lambda layers"
  value       = try(aws_lambda_layer_version.create_lambda_layers, null)
}

output "lambda_layer_arns" {
  description = "Lambda layer ARNs"
  value       = try(aws_lambda_layer_version.create_lambda_layers[*].arn, null)
}

output "log_group" {
  description = "Lambda log group"
  value       = try(aws_cloudwatch_log_group.create_log_group, null)
}

output "log_group_arn" {
  description = "Lambda log group ARN"
  value       = try(aws_cloudwatch_log_group.create_log_group.arn, null)
}

output "url_config" {
  description = "Lambda URL configuration"
  value       = try(aws_lambda_function_url.create_url[0], null)
}

output "lambda_url" {
  description = "Lambda URL"
  value       = try(aws_lambda_function_url.create_url[0].function_url, null)
}

output "iam_lambda_role" {
  description = "IAM lambda Role"
  value       = try(aws_iam_role.create_iam_for_lambda[0], null)
}

output "iam_lambda_role_arn" {
  description = "IAM lambda Role ARN"
  value       = try(aws_iam_role.create_iam_for_lambda[0].arn, null)
}

output "iam_policies" {
  description = "IAM policies"
  value       = try(aws_iam_policy.create_policies, null)
}

output "iam_policies_arns" {
  description = "IAM policies ARNs"
  value       = try(aws_iam_policy.create_policies[*].arn, null)
}

output "iam_policies_attachments" {
  description = "IAM policies attachments"
  value       = try(aws_iam_role_policy_attachment.create_attachments, null)
}

output "iam_policies_allow_vpc" {
  description = "IAM policies allow VPC"
  value       = try(aws_iam_role_policy_attachment.iam_role_policy_attachment_lambda_vpc_access_execution[0], null)
}

output "events_sources" {
  description = "Events sources"
  value       = try(aws_lambda_event_source_mapping.create_event, null)
}
