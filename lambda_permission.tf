/*resource "aws_lambda_permission" "lambdas" {
  count               = length(local.endpoints)
  action              = var.lambda_permission_action
  event_source_token  = var.lambda_permission_event_source_token
  function_name       = split("/",split("function:",local.endpoints[count.index].integration.uri)[1])[0]
  principal           = var.lambda_permission_principal
  qualifier           = var.lambda_permission_qualifier
  source_account      = var.lambda_permission_source_account
  source_arn          = var.lambda_permission_source_arn
  statement_id        = var.lambda_permission_statement_id
}*/

locals {
  # Terraform does not support 'lazy evaluation', or we could create lambda_endpoint_map in one line using the '&&' operator.
  endpoint_maps_containing_uri          = {for key, value in local.endpoints: value.identifier => value if (contains(keys(value.integration_request), "uri") ? value.integration_request.uri != null : false)}
  lambda_endpoint_map                   = {for key, value in local.endpoint_maps_containing_uri: key => value if length(regexall("arn\\:aws\\:lambda", value.integration_request.uri)) > 0}
}


resource "aws_lambda_permission" "lambdas" {
  for_each            = local.lambda_endpoint_map
  action              = var.lambda_permission_action
  event_source_token  = var.lambda_permission_event_source_token
  function_name       = regex("function:([^:\\/]*)", each.value.integration_request.uri)[0]
  principal           = var.lambda_permission_principal
  qualifier           = length(regexall("function:[^:\\/]*:\\d+", each.value.integration_request.uri)) == 0 ? null : regex("function:[^:\\/]*\\:(\\d+)", each.value.integration_request.uri)[0]
  source_account      = var.lambda_permission_source_account
  source_arn          = var.lambda_permission_source_arn
  statement_id_prefix = var.lambda_permission_statement_id_prefix
  depends_on = [aws_cloudformation_stack.resources]
}