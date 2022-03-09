# DynamoDB Table
resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ShortenURL"
  range_key      = "OriginalURL"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "ShortenURL"
    type = "S"
  }

  attribute {
    name = "OriginalURL"
    type = "S"
  }
  
  replica {
    region_name = "us-west-2"
  }

  tags = {
    Name        = "dynamodb-table-POC"
    Environment = "POC"
  }
}


# # DynamoDB Autoscaling Policy
# resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = aws_dynamodb_table.dynamodb-table.id
#   scalable_dimension = "dynamodb:table:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
#   name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }

#     target_value = 70
#   }
# }