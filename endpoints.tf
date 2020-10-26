locals {
  path_parts_map = toset(flatten([
  for path in var.endpoints[*].path: [
  for count in range(0, length(split("/", path))): {
    path             = trim(regex(join("", [
      "(?:[^/]*/*){",
      count + 1,
      "}"]), path), "/")
    path_hash        = md5(trim(regex(join("", [
      "(?:[^/]*/*){",
      count + 1,
      "}"]), path), "/"))
    path_parent      = trim(regex(join("", [
      "(?:[^/]*/*){",
      count,
      "}"]), path), "/")
    path_parent_hash = md5(trim(regex(join("", [
      "(?:[^/]*/*){",
      count,
      "}"]), path), "/"))
    path_part        = split("/", path)[count]
    path_part_hash   = md5(split("/", path)[count])
  }
  ]
  ]))

  endpoints = flatten([
  for endpoint in var.endpoints[*]: [
  for method in endpoint.methods:  {
    path                 = replace(endpoint.path, "/^//", "")
    method               = lookup(method, "method", var.method_request_default.method)
    identifier           = "${replace(endpoint.path, "/^//", "")}/${lookup(method, "method", var.method_request_default.method)}"
    integration_request  = lookup(method, "integration_request", var.integration_request_default)
    integration_response = lookup(method, "integration_response", var.integration_response_default)
    method_request       = lookup(method, "method_request", var.method_request_default)

    # We do not merge with default, because that may add extra unwanted responses.
    method_response = contains(keys(method), "method_response") ? method.method_response : var.method_response_default
  }
  ]
  ])

  method_response_failover = var.method_response_default[200]
  method_response_list     = flatten([
  for endpoint in local.endpoints[*]: [
  for key, method_response in endpoint.method_response: {
    method              = endpoint.method
    path                = endpoint.path
    identifier          = "${endpoint.identifier}/${key}"
    status_code         = method_response.status_code
    response_models     = lookup(method_response, "response_models", local.method_response_failover.response_models)
    response_parameters = lookup(method_response, "response_parameters", local.method_response_failover.response_parameters)
  }
  ]
  ])

  method_responses = {
  for method_response in local.method_response_list:
  method_response.identifier => method_response
  }

  integration_response_failover = var.integration_response_default[200]
  integration_response_list     = flatten([
  for endpoint in local.endpoints[*]: [
  for key, integration_response in endpoint.integration_response: {
    method              = endpoint.method
    path                = endpoint.path
    identifier          = "${endpoint.identifier}/${key}"
    status_code         = lookup(integration_response, "status_code", local.integration_response_failover.status_code)
    selection_pattern   = lookup(integration_response, "selection_pattern", local.integration_response_failover.selection_pattern)
    response_templates  = lookup(integration_response, "response_templates", local.integration_response_failover.response_templates)
    response_parameters = lookup(integration_response, "response_parameters", local.integration_response_failover.response_parameters)
    content_handling    = lookup(integration_response, "content_handling", local.integration_response_failover.content_handling)
  }
  ]
  ])

  integration_responses = {
  for integration_response in local.integration_response_list:
  "${integration_response.identifier}" => integration_response
  }

  method_request_list = flatten([
  for endpoint in local.endpoints[*]: {
    identifier     = endpoint.identifier
    method_request = merge(var.method_request_default, endpoint.method_request)
    path           = endpoint.path
    method         = endpoint.method
  }
  ])

  method_requests = {
  for item in local.method_request_list:
  item.identifier => merge({
    path = item.path
  }, item.method_request, {
    method = item.method
  })
  }

  # Integration request is a pain because we need a default value for lambda integrations
  # and one for all other types
  integration_request_list              = flatten([
  for endpoint in local.endpoints[*]: {
    identifier          = endpoint.identifier
    integration_request = merge(endpoint.integration_request, {
      method = endpoint.method
    })
    path                = endpoint.path
    method              = endpoint.method
  }
  ])
  # Split up integration requests into 2 groups - one for lambdas and one for all others
  integration_request_list_with_uri_raw = {for key, value in local.integration_request_list: value.identifier => value if (contains(keys(value.integration_request), "uri") ? value.integration_request.uri != null : false)}
  lambda_integration_requests_raw       = {for key, value in local.integration_request_list_with_uri_raw: key => value if length(regexall("arn\\:aws\\:lambda", value.integration_request.uri)) > 0}

  nonlambda_integration_requests_with_uri_raw = {for key, value in local.integration_request_list_with_uri_raw: key => value if length(regexall("arn\\:aws\\:lambda", value.integration_request.uri)) == 0}
  integration_requests_without_uri_raw        = {for key, value in local.integration_request_list: value.identifier => value if contains(keys(value.integration_request), "uri") ?  value.integration_request.uri == null : true}

  nonlambda_integration_requests_raw = merge(local.integration_requests_without_uri_raw, local.nonlambda_integration_requests_with_uri_raw)

  lambda_integration_requests    = {for key, value in local.lambda_integration_requests_raw: key => merge(var.integration_request_lambda_default, value, value.integration_request)}
  nonlambda_integration_requests = {for key, value in local.nonlambda_integration_requests_raw: key => merge(var.integration_request_default, value, value.integration_request )}

  integration_requests = merge(local.lambda_integration_requests, local.nonlambda_integration_requests)

  #integration_requests = {
  #for item in local.integration_request_list:
  #item.identifier => merge({path = item.path}, item.integration_request)
  #}
}

resource "null_resource" "print_shit" {
  provisioner "local-exec" {
    command     = "echo lambda_integration_requests_with_default: ${jsonencode({})}"
    working_dir = "."
  }
  triggers = {
    trigger = uuid()
  }
}


output "endpoints" {
  value = var.endpoints
}

# Method Request
#resource "aws_api_gateway_method" "method_requests" {
#  for_each             = local.method_requests
#  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
#  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
#  http_method          = each.value.method
#  authorization        = each.value.authorization
#  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
#  authorization_scopes = each.value.authorization_scopes
#  api_key_required     = each.value.api_key_required
#  request_models       = each.value.request_models
#  request_validator_id = aws_api_gateway_request_validator.validator.id
#  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
#  depends_on           = [aws_cloudformation_stack.resources]
#}
#
## Integration Request
#resource "aws_api_gateway_integration" "integration_requests" {
#  for_each                = local.integration_requests
#  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
#  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
#  http_method             = each.value.method
#  integration_http_method = each.value.integration_http_method
#  type                    = each.value.type
#  connection_type         = each.value.connection_type
#  connection_id           = each.value.connection_id
#  uri                     = each.value.uri
#  credentials             = each.value.credentials
#  request_templates       = each.value.request_templates
#  request_parameters      = each.value.request_parameters
#  passthrough_behavior    = each.value.passthrough_behavior
#  cache_key_parameters    = each.value.cache_key_parameters
#  cache_namespace         = each.value.cache_namespace
#  content_handling        = each.value.content_handling
#  timeout_milliseconds    = each.value.timeout_milliseconds
#
#  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.method_requests]
#}
#
#resource "aws_api_gateway_method_response" "method_responses" {
#  for_each            = {for key, value in local.method_responses: key => value if value.method == "GET"}
#  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
#  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
#  http_method         = each.value.method
#  status_code         = each.value.status_code
#  response_models     = each.value.response_models
#  response_parameters = each.value.response_parameters
#  depends_on          = [aws_api_gateway_method.method_requests]
#}
#
## NOTE there is a bug with the AWS API Gateway provider that causes terraform to fail if building more than one integration response for a single endpoint with multiple methods.
## Retrying a couple times will succeed. See https://github.com/terraform-providers/terraform-provider-aws/issues/483
## Integration Response
#resource "aws_api_gateway_integration_response" "integration_responses" {
#  for_each            = local.integration_responses#{for key, value in local.integration_responses: key => value if value.method == "GET"}
#  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
#  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
#  http_method         = each.value.method
#  status_code         = each.value.status_code
#  selection_pattern   = each.value.selection_pattern
#  response_templates  = each.value.response_templates
#  response_parameters = each.value.response_parameters
#  content_handling    = each.value.content_handling
#  depends_on          = [aws_api_gateway_method.method_requests, aws_api_gateway_method_response.method_responses, aws_api_gateway_integration.integration_requests]
#}