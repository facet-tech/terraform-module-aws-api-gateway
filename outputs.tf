output "rest_api" {
  value = aws_api_gateway_rest_api.rest_api
}

output "iam_role" {
  value = aws_iam_role.role
}

output "constants" {
  value = var.constants
}

output "rest_api_execution_arn" {
  value = "arn:aws:execute-api:${data.aws_region.current_user.name}:${data.aws_caller_identity.current_user.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*"
}

output "tags" {
  value = module.default_tags.tags
}