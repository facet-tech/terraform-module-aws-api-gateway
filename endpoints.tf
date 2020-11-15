locals {
  path_parts_map = toset(flatten([
     for path in var.endpoints[*].path: [
       for count in range(0, length(split("/", path))): {
          path             =     trim(regex(join("", ["(?:[^/]*/*){", count + 1, "}"]), path), "/")
          path_hash        = md5(trim(regex(join("", ["(?:[^/]*/*){", count + 1, "}"]), path), "/"))
          path_parent      =     trim(regex(join("", ["(?:[^/]*/*){", count,     "}"]), path), "/")
          path_parent_hash = md5(trim(regex(join("", ["(?:[^/]*/*){", count,     "}"]), path), "/"))
          path_part        =     split("/", path)[count]
          path_part_hash   = md5(split("/", path)[count])
       }
     ]
  ]))

  endpoints = flatten([
     for endpoint in var.endpoints[*]: [
        for method in endpoint.methods:  {
           path        = replace(endpoint.path, "/^//", "")
           method      = merge(var.method_default, method)
           integration = merge(var.integration_default, method.integration_request)
           //subobject?
        }
     ]
  ])

  path_endpoint_map = {
     for endpoint in local.endpoints:
        endpoint.path => endpoint
  }
}

output "endpoints" {
  value = var.endpoints
}

resource "aws_api_gateway_method" "methods" {
  for_each             = local.path_endpoint_map
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.key), uuid())
  http_method          = each.value.method.method
  authorization        = each.value.method.authorization
  authorizer_id        = each.value.method.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.method.authorizer_id].id : each.value.method.authorizer_id
  authorization_scopes = each.value.method.authorization_scopes
  api_key_required     = each.value.method.api_key_required
  request_models       = each.value.method.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.method.request_parameters == null ? {} : merge(var.method_default.request_parameters, each.value.method.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources]
}

resource "aws_api_gateway_integration" "integrations" {
  for_each                = local.path_endpoint_map
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id            = lookup(aws_cloudformation_stack.resources.outputs, md5(each.key), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method.method
  integration_http_method = each.value.integration.integration_http_method
  type                    = each.value.integration.type
  connection_type         = each.value.integration.connection_type
  connection_id           = each.value.integration.connection_id
  uri                     = each.value.integration.uri
  credentials             = aws_iam_role.role.arn
  request_templates       = each.value.integration.request_templates
  request_parameters      = each.value.integration.request_parameters
  passthrough_behavior    = each.value.integration.passthrough_behavior
  cache_key_parameters    = each.value.integration.cache_key_parameters
  cache_namespace         = each.value.integration.cache_namespace
  content_handling        = each.value.integration.content_handling
  timeout_milliseconds    = each.value.integration.timeout_milliseconds
  depends_on              = [aws_cloudformation_stack.resources, aws_api_gateway_method.methods]
}