# DynamoDB Table
resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.name
  billing_mode   = "PROVISIONED"
  hash_key       = "ShortenURL"
  range_key      = "OriginalURL"
  read_capacity  = 100
  write_capacity = 100

  attribute {
    name = "ShortenURL"
    type = "S"
  }

  attribute {
    name = "OriginalURL"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-POC"
    Environment = "POC"
  }

  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
  
  point_in_time_recovery {
    enabled = "true"
  }

}


# DynamoDB Autoscaling Policy
resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  max_capacity       = 2000
  min_capacity       = 100
  resource_id        = "table/${aws_dynamodb_table.dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

# DynamoDB Autoscaling Policy
resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  max_capacity       = 2000
  min_capacity       = 100
  resource_id        = "table/${aws_dynamodb_table.dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}