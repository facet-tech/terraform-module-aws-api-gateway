locals {
  authorizers = {
  for authorizer in var.authorizers:
     "${var.name}-${authorizer.name}-${var.environment}" => merge(var.authorizer_default,authorizer)
  }
}

resource "aws_api_gateway_authorizer" "authorizer" {
  for_each                         = local.authorizers
  authorizer_uri                   = each.value.authorizer_uri
  name                             = each.key
  rest_api_id                      = aws_api_gateway_rest_api.rest_api.id
  identity_source                  = each.value.identity_source
  type                             = each.value.type
  authorizer_credentials           = each.value.authorizer_credentials
  authorizer_result_ttl_in_seconds = each.value.authorizer_result_ttl_in_seconds
  identity_validation_expression   = each.value.identity_validation_expression
  provider_arns                    = each.value.provider_arns
}

