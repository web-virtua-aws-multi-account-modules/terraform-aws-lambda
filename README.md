# AWS Lambda Functions for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a Lambda Functions across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of Lambda configurations for this module:

- Lambda function
- Lambda function URL
- Lambda layer
- Lambda IAM role
- Lambda event source mapping
- IAM policy
- Cloudwatch log group

## Usage exemples

### Lambda function with URL, layer and application files from local and using default VPC, in this case the zipe file already exists

```hcl
module "lambda_layer_file_local" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name     = "tf-test-lambda-function"
  file_name       = "./file-lambda-layer/app.zip"
  handler_file    = "app/index.handler"
  make_lambda_url = true
  aws_account_id  = 649......777

  lambda_layers = [
    {
      name                = "tf-test-lambda-layer-file-local-1"
      file_name           = "./file-lambda-layer/code.zip"
      compatible_runtimes = ["nodejs16.x"]
      description         = "Teste layer from file local 1.0"
    }
  ]

  providers = {
    aws = aws.alias_profile_a
  }
}
```

### Lambda function with URL, layer and application files from local and using default VPC, in this case the files will be ziped during the creation

```hcl
module "lambda_layer_file_local" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name             = "tf-test-lambda-function"
  lambda_source_code_path = "./application/app/dist"
  lambda_compressed_code  = "./application/app/dist.zip"
  file_name               = "./application/app/dist.zip"
  handler_file            = "index.handler"
  runtime                 = "nodejs16.x"
  make_lambda_url         = true
  aws_account_id          = 649......777

  envs = {
    ENVIRONMENT = "production"
  }

  lambda_layers = [
    {
      name                = "tf-lambda-api-layer-test"
      file_name           = "./application/app_dependencies/nodejs.zip"
      compatible_runtimes = ["nodejs16.x"]
      description         = "Teste layer from file local 1.0"
      source_code_path    = "./application/app/nodejs"
      compressed_code     = "./application/app/nodejs.zip"
      compress_type       = "zip"
    }
  ]

  providers = {
    aws = aws.alias_profile_a
  }
}
```

### Lambda function with URL, layer and application files from bucket S3 and using default VPC

```hcl
module "lambda_layer_file_local" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name     = "tf-test-bucket-lambda-function"
  bucket_name     = "test-bucket"
  bucket_object   = "app-test/app.zip"
  handler_file    = "app/index.handler"
  make_lambda_url = true
  aws_account_id  = 649......777

  lambda_layers = [
    {
      name                = "tf-test-lambda-layer-bucket-1"
      bucket_name         = "test-bucket"
      bucket_object       = "app-test/app.zip"
      compatible_runtimes = ["nodejs16.x"]
      description         = "Teste layer from bucket"
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Lambda function with URL, application files from local and using customized VPC

```hcl
module "lambda_layer_file_local" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name     = "tf-test-lambda-function-vpc"
  file_name       = "./file-lambda-layer/app.zip"
  handler_file    = "app/index.handler"
  make_lambda_url = true
  aws_account_id  = "*"

  security_group_ids = [
    "sg-018620a...764c"
  ]

  subnet_ids = [
    "subnet-0eff3...bde8",
    "subnet-0ecce...cfd9"
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Lambda function without URL, application files from local and custom policies

```hcl
module "lambda_with_envs_without_url" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name     = "tf-test-lambda-function-with-envs-without_url"
  file_name       = "./file-lambda-layer/app.zip"
  handler_file    = "app/index.handler"
  aws_account_id  = 649......777

  envs = {
    api = "http://test.com.br"
  }

  custom_policies = [
    {
      name        = "tf-policy-test"
      path        = "/"
      description = "IAM policy for logging from a lambda"
      policy = {
        "Version" : "2012-10-17",
        "Id" : "PutObjPolicy",
        "Statement" : [{
          "Sid" : "DenyObjectsThatAreNotSSEKMS"
          "Effect" : "Deny",
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::test-bucket/*"
        }]
      }
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Lambda function without URL, application files from local, custom policies and attach event source

```hcl
module "lambda_with_envs_without_url" {
  source = "web-virtua-aws-multi-account-modules/lambda/aws"

  lambda_name     = "tf-test-lambda-policy-and-event-source"
  file_name       = "./file-lambda-layer/app.zip"
  handler_file    = "app/index.handler"
  make_lambda_url = true
  aws_account_id  = 65...257 # luby root
  region          = "us-east-2"

  custom_policies = [
    {
      name        = "tf-allow-sqs-policy"
      path        = "/"
      description = "IAM policy for sqs from a lambda"
      policy = {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "sqs:*"
            ],
            "Resource" : "arn:aws:sqs:us-east-2:65...257:fila-manual",
            "Effect" : "Allow"
          }
        ]
      }
    }
  ]

  events_sources = [
    {
      event_source_arn = "arn:aws:sqs:us-east-2:65...257:fila-test"
      access_configuration = [
        {
          type = "VPC_SUBNET"
          uri  = "subnet-090e...6e1"
        }
      ]
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| region | `string` | `us-east-1` | no | Region that received the logs, can be one region or * for all regions | `-` |
| aws_account_id | `string` | `*` | no | AWS account ID, can be one account or * for any account | `-` |
| lambda_source_code_path | `string` | `null` | no | Lambda file zip path with the files ziped to application | `-` |
| lambda_compressed_code | `string` | `null` | no | Lambda source code compressed to zip files | `-` |
| lambda_compress_type | `string` | `zip` | no | Type of compression to source code | `-` |
| file_name | `string` | `null` | no | The file_name variable send the files from your local machine to create the lambda function, if defined bucket_name variable cannot be used, ex: file-name.zip | `-` |
| bucket_file_name | `string` | `null` | no | Bucket name to lambda layer | `-` |
| bucket_name | `string` | `null` | no | Bucket name that store the lambda resources, is optional, can be create only on lambda or in bucket | `-` |
| bucket_object | `string` | `null` | no | The version of the bucket object | `-` |
| lambda_name | `string` | `null` | yes | Unique name to lambda function | `-` |
| handler_file | `string` | `null` | yes | It variable must have the file name that start the application, ex: index.handler, It's required to start the lambda function | `-` |
| runtime | `string` | `nodejs16.x` | no | Identifier of the function's runtime | `-` |
| lambda_role_arn | `string` | `null` | no | The main trust IAM lambda role for this lambda function | `-` |
| image_uri | `string` | `null` | no | ECR image URI containing the function's deployment package. Conflicts with filename, s3_bucket, s3_key, and s3_object_version | `-` |
| ephemeral_storage_size | `number` | `null` | no | The amount of Ephemeral storage(/tmp) to allocate for the Lambda Function in MB. This parameter is used to expand the total amount of Ephemeral storage available, beyond the default amount of 512MB | `-` |
| envs | `map(any)` | `null` | no | Map of environment variables that are accessible from the function code during execution | `-` |
| layers_arn | `list(string)` | `null` | no | List with layers to use in lambda function, can be to use up to 5 layers | `-` |
| architectures | `list(string)` | `null` | no | Instruction set architecture for your Lambda function. Valid values are [\"x86_64\"] and [\"arm64\"] | `*`["x86_64"] <br> `*`["arm64"] |
| subnet_ids | `list(string)` | `null` | no | Subnet ID's | `-` |
| security_group_ids | `list(string)` | `null` | no | Security groups ids | `-` |
| timeout | `number` | `30` | no | Timeout to lambda function | `-` |
| memory_size | `number` | `128` | no | Memory size to lambda function | `-` |
| make_lambda_url | `bool` | `false` | no | Define if will be creating a lambda URL | `*`false <br> `*`true |
| authorization_type | `string` | `NONE` | no | The type of authentication that the function URL uses. Set to AWS_IAM to restrict access to authenticated IAM users only. Set to NONE to bypass IAM authentication and create a public endpoint | `-` |
| allow_credentials | `bool` | `true` | no | Allow credentials to URL access | `*`false <br> `*`true |
| allow_origins | `list(string)` | `["*"]` | no | Allow origins to lambda URL | `-` |
| allow_methods | `list(string)` | `["*"]` | no | Allow methods to lambda URL | `-` |
| allow_headers | `list(string)` | `["date", "keep-alive"]` | no | Allow headers to lambda URL | `-` |
| expose_headers | `list(string)` | `["keep-alive", "date"]` | no | Expose headers to lambda URL | `-` |
| max_age | `number` | `86400` | no | Max age to lamda URL | `-` |
| cloudwatch_log_group_name | `string` | `null` | no | Cloudwatch log group name | `-` |
| cloudwatch_log_group_path | `string` | `/` | no | Cloudwatch log group path | `-` |
| cloudwatch_log_group_description | `string` | `null` | no | Cloudwatch log group description | `-` |
| logs_retention_in_days | `number` | `7` | no | Logs retention days | `-` |
| lambda_assume_role | `any` | `object` | no | Assume role to lambda functions | `-` |
| lambda_logging_policy | `any` | `null` | no | Policy to logs to lambda functions | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default | `*`false <br> `*`true |
| tags_iam_role | `map(any)` | `{}` | no | Tags to IAM Role | `-` |
| tags_cloudwatch_log_group | `map(any)` | `{}` | no | Tags to cloudwatch log group | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| custom_policies | `list(object)` | `null` | no | Policies custom to lambda function | `-` |
| lambda_layers | `list(object)` | `null` | no | Lambda layers to lambda function | `-` |
| events_sources | `list(object)` | `null` | no | Event sources to attach on lambda function | `-` |

* Model of variable custom_policies
```hcl
variable "custom_policies" {
  description = "Policies custom to lambda function"
  type = list(object({
    name        = string
    policy      = any
    path        = optional(string)
    description = optional(string)
  }))
  default = [
    {
      name        = "tf-allow-sqs-policy"
      path        = "/"
      description = "IAM policy for sqs from a lambda"
      policy = {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "sqs:*"
            ],
            "Resource" : "arn:aws:sqs:us-east-2:655...257:fila-test",
            "Effect" : "Allow"
          }
        ]
      }
    }
  ]
}
```

* Model of variable lambda_layers
```hcl
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
  default = lambda_layers = [
    {
      name                = "tf-test-lambda-layer-bucket-1"
      bucket_name         = "test-bucket"
      bucket_object       = "app-test/app.zip"
      compatible_runtimes = ["nodejs16.x"]
      description         = "Teste layer from bucket"
    }
  ]
}
```

* Model of variable events_sources
```hcl
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
  default = [
    {
      event_source_arn = "arn:aws:sqs:us-east-2:65...257:fila-test"
      access_configuration = [
        {
          type = "VPC_SUBNET"
          uri  = "subnet-090...6e1"
        }
      ]
    }
  ]
}
```

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.create_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.create_lambda_layers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_cloudwatch_log_group.create_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_function_url.create_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_iam_role.create_iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.create_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.create_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_role_policy_attachment_lambda_vpc_access_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.create_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |


## Outputs

| Name | Description |
|------|-------------|
| `lambda_function` | Lambda function |
| `lambda_function_arn` | Lambda function ARN |
| `lambda_function_role` | Lambda function role |
| `lambda_function_invoke_arn` | Lambda function invoke ARN |
| `lambda_function_invoke_memory_size` | Lambda function memory size |
| `lambda_function_invoke_runtime` | Lambda function runtime |
| `lambda_layers` | Lambda layers |
| `lambda_layer_arns` | Lambda layer ARNs |
| `log_group` | Lambda log group |
| `log_group_arn` | Lambda log group ARN |
| `url_config` | Lambda URL configuration |
| `lambda_url` | Lambda URL |
| `iam_lambda_role` | IAM lambda Role |
| `iam_lambda_role_arn` | IAM lambda Role ARN |
| `iam_policies` | IAM policies |
| `iam_policies_arns` | IAM policies ARNs |
| `iam_policies_attachments` | IAM policies attachments |
| `iam_policies_allow_vpc` | IAM policies allow VPC |
| `events_sources` | Events sources |
