resource "aws_lambda_layer_version" "create_lambda_layers" {
  count = var.lambda_layers != null ? length(var.lambda_layers) : 0

  layer_name          = var.lambda_layers[count.index].name
  filename            = var.lambda_layers[count.index].file_name
  s3_bucket           = var.lambda_layers[count.index].bucket_name
  s3_key              = var.lambda_layers[count.index].bucket_object
  s3_object_version   = var.lambda_layers[count.index].bucket_object_version
  compatible_runtimes = var.lambda_layers[count.index].compatible_runtimes
  source_code_hash    = var.lambda_layers[count.index].source_code_hash
  description         = var.lambda_layers[count.index].description
  skip_destroy        = try(var.lambda_layers[count.index].skip_destroy, false)
}

resource "aws_lambda_function" "create_lambda_function" {
  function_name     = var.lambda_name
  runtime           = var.runtime
  handler           = try(split(".", var.handler_file)[1], null) == "handler" ? var.handler_file : "${var.handler_file}.handler"
  role              = try(aws_iam_role.create_iam_for_lambda[0].arn, var.lambda_role_arn)
  layers            = try(aws_lambda_layer_version.create_lambda_layers[*].arn, var.layers_arn)
  filename          = var.file_name
  s3_bucket         = var.bucket_name
  s3_key            = var.bucket_object
  s3_object_version = var.bucket_object_version
  architectures     = var.architectures
  image_uri         = var.image_uri
  timeout           = var.timeout
  memory_size       = var.memory_size

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []

    content {
      size = var.ephemeral_storage_size
    }
  }

  dynamic "environment" {
    for_each = var.envs != null ? [1] : []

    content {
      variables = var.envs
    }
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null ? [1] : []

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}

resource "aws_cloudwatch_log_group" "create_log_group" {
  name              = local.log_group_name
  retention_in_days = var.logs_retention_in_days
  tags              = merge(var.tags_cloudwatch_log_group, var.use_tags_default ? local.tags_cloudwatch_log_group_default : {})
}

# Create URL https to execute your lambda function with CORS enable.
resource "aws_lambda_function_url" "create_url" {
  count = var.make_lambda_url ? 1 : 0

  function_name      = aws_lambda_function.create_lambda_function.function_name
  authorization_type = var.authorization_type

  cors {
    allow_credentials = var.allow_credentials
    allow_origins     = var.allow_origins
    allow_methods     = var.allow_methods
    allow_headers     = var.allow_headers
    expose_headers    = var.expose_headers
    max_age           = var.max_age
  }
}

resource "aws_lambda_event_source_mapping" "create_event" {
  count = var.events_sources != null ? length(var.events_sources) : 0

  function_name     = aws_lambda_function.create_lambda_function.arn
  event_source_arn  = var.events_sources[count.index].event_source_arn
  starting_position = var.events_sources[count.index].starting_position
  batch_size        = var.events_sources[count.index].batch_size
  enabled           = var.events_sources[count.index].enabled
  topics            = var.events_sources[count.index].topics
  queues            = var.events_sources[count.index].queues

  bisect_batch_on_function_error     = var.events_sources[count.index].bisect_batch_on_function_error
  maximum_batching_window_in_seconds = var.events_sources[count.index].maximum_batching_window_in_seconds
  maximum_record_age_in_seconds      = var.events_sources[count.index].maximum_record_age_in_seconds
  maximum_retry_attempts             = var.events_sources[count.index].maximum_retry_attempts
  parallelization_factor             = var.events_sources[count.index].parallelization_factor
  starting_position_timestamp        = var.events_sources[count.index].starting_position_timestamp
  function_response_types            = var.events_sources[count.index].function_response_types

  dynamic "self_managed_event_source" {
    for_each = var.events_sources[count.index].endpoints != null ? [1] : []

    content {
      endpoints = {
        KAFKA_BOOTSTRAP_SERVERS = var.events_sources[count.index].endpoints
      }
    }
  }

  dynamic "destination_config" {
    for_each = var.events_sources[count.index].on_failure_sqs_arn != null ? [1] : []

    content {
      on_failure {
        destination_arn = var.events_sources[count.index].on_failure_sqs_arn
      }
    }
  }

  dynamic "filter_criteria" {
    for_each = var.events_sources[count.index].filter_criteria != null ? [1] : []

    content {
      filter {
        pattern = jsonencode(var.events_sources[count.index].filter_criteria)
      }
    }
  }

  dynamic "source_access_configuration" {
    for_each = try(var.events_sources[count.index].access_configuration, [])

    content {
      type = source_access_configuration.value.type
      uri  = source_access_configuration.value.uri
    }
  }
}
