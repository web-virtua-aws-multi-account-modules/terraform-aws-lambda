variable "region" {
  description = "Region that received the logs, can be one region or * for all regions"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID, can be one account or * for any account"
  type        = any
  default     = "*"
}

variable "lambda_source_code_path" {
  description = "Lambda file zip path with the files ziped to application"
  type        = string
  default     = null
}

variable "lambda_compressed_code" {
  description = "Lambda source code compressed to zip files"
  type        = string
  default     = null
}

variable "lambda_compress_type" {
  description = "Type of compression to source code"
  type        = string
  default     = "zip"
}

variable "file_name" {
  description = "The file_name variable send the files from your local machine to create the lambda function, if defined bucket_name variable cannot be used, ex: file-name.zip"
  type        = string
  default     = null
}

variable "bucket_file_name" {
  description = "Bucket name to lambda layer"
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Bucket name that store the lambda resources, is optional, can be create only on lambda or in bucket"
  type        = string
  default     = null
}

variable "bucket_object" {
  description = "The object name "
  type        = string
  default     = null
}

variable "bucket_object_version" {
  description = "The version of the bucket object"
  type        = string
  default     = null
}

variable "lambda_name" {
  description = "Unique name to lambda function"
  type        = string
}

variable "handler_file" {
  description = "It variable must have the file name that start the application, ex: index.handler, It's required to start the lambda function"
  type        = string
}

variable "runtime" {
  description = "Identifier of the function's runtime"
  type        = string
  default     = "nodejs16.x"
}

variable "lambda_role_arn" {
  description = "The main trust IAM lambda role for this lambda function"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "ECR image URI containing the function's deployment package. Conflicts with filename, s3_bucket, s3_key, and s3_object_version"
  type        = string
  default     = null
}

variable "ephemeral_storage_size" {
  description = "The amount of Ephemeral storage(/tmp) to allocate for the Lambda Function in MB. This parameter is used to expand the total amount of Ephemeral storage available, beyond the default amount of 512MB"
  type        = number
  default     = null
}

variable "envs" {
  description = "Map of environment variables that are accessible from the function code during execution"
  type        = map(any)
  default     = null
}

variable "layers_arn" {
  description = "List with layers to use in lambda function, can be to use up to 5 layers"
  type        = list(string)
  default     = null
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function. Valid values are [\"x86_64\"] and [\"arm64\"]"
  type        = list(string)
  default     = null
}

variable "subnet_ids" {
  description = "Subnet ID's"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security groups ids"
  type        = list(string)
  default     = null
}

variable "timeout" {
  description = "Timeout to lambda function"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memory size to lambda function"
  type        = number
  default     = 128
}

variable "make_lambda_url" {
  description = "Define if will be creating a lambda URL"
  type        = bool
  default     = false
}

variable "authorization_type" {
  description = "The type of authentication that the function URL uses. Set to AWS_IAM to restrict access to authenticated IAM users only. Set to NONE to bypass IAM authentication and create a public endpoint"
  type        = string
  default     = "NONE"
}

variable "allow_credentials" {
  description = "Allow credentials to URL access"
  type        = bool
  default     = true
}

variable "allow_origins" {
  description = "Allow origins to lambda URL"
  type        = list(string)
  default     = ["*"]
}

variable "allow_methods" {
  description = "Allow methods to lambda URL"
  type        = list(string)
  default     = ["*"]
}

variable "allow_headers" {
  description = "Allow headers to lambda URL"
  type        = list(string)
  default     = ["date", "keep-alive"]
}

variable "expose_headers" {
  description = "Expose headers to lambda URL"
  type        = list(string)
  default     = ["keep-alive", "date"]
}

variable "max_age" {
  description = "Max age to lamda URL"
  type        = number
  default     = 86400
}

variable "cloudwatch_log_group_name" {
  description = "Cloudwatch log group name"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_path" {
  description = "Cloudwatch log group path"
  type        = string
  default     = "/"
}

variable "cloudwatch_log_group_description" {
  description = "Cloudwatch log group description"
  type        = string
  default     = null
}

variable "logs_retention_in_days" {
  description = "Logs retention days"
  type        = number
  default     = 7
}

variable "lambda_assume_role" {
  description = "Assume role to lambda functions"
  type        = any
  default = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  }
}

variable "lambda_logging_policy" {
  description = "Policy to logs to lambda functions"
  type        = any
  default     = null
}

variable "use_tags_default" {
  description = "If true will be use the tags default"
  type        = bool
  default     = true
}

variable "tags_iam_role" {
  description = "Tags to IAM Role"
  type        = map(any)
  default     = {}
}

variable "tags_cloudwatch_log_group" {
  description = "Tags to cloudwatch log group"
  type        = map(any)
  default     = {}
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "custom_policies" {
  description = "Policies custom to lambda function"
  type = list(object({
    name        = string
    policy      = any
    path        = optional(string)
    description = optional(string)
  }))
  default = null
}

variable "lambda_layers" {
  description = "Lambda layers to lambda function"
  type = list(object({
    name                  = string
    file_name             = optional(string)
    bucket_name           = optional(string)
    bucket_object         = optional(string)
    bucket_object_version = optional(string)
    compatible_runtimes   = optional(list(string))
    source_code_hash      = optional(number)
    description           = optional(string)
    skip_destroy          = optional(bool)
    compressed_code       = optional(string)
    source_code_path      = optional(string)
    compress_type         = optional(string)
  }))
  default = null
}

variable "events_sources" {
  description = "Event sources to attach on lambda function"
  type = list(object({
    event_source_arn                   = string
    starting_position                  = optional(string)
    batch_size                         = optional(number)
    enabled                            = optional(bool)
    endpoints                          = optional(string)
    on_failure_sqs_arn                 = optional(string)
    maximum_concurrency_sqs            = optional(string)
    bisect_batch_on_function_error     = optional(bool)
    maximum_batching_window_in_seconds = optional(number)
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    parallelization_factor             = optional(number)
    starting_position_timestamp        = optional(string)
    topics                             = optional(list(string))
    queues                             = optional(list(string))
    function_response_types            = optional(list(string))
    filter_criteria                    = optional(any)
    access_configuration = optional(list(object({
      type = optional(string)
      uri  = optional(string)
    })))
  }))
  default = null
}
