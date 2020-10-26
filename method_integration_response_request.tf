# Method Request
resource "aws_api_gateway_method" "any_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "ANY"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer]
}

# Integration Request
resource "aws_api_gateway_integration" "any_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "ANY"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests]
}

resource "aws_api_gateway_method_response" "any_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "ANY"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests]
}

resource "aws_api_gateway_integration_response" "any_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "ANY"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method_response.any_method_responses]
}# Method Request
resource "aws_api_gateway_method" "delete_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "DELETE"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "delete_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "DELETE"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_integration.any_integration_requests]
}

resource "aws_api_gateway_method_response" "delete_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "DELETE"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method_response.any_method_responses]
}

resource "aws_api_gateway_integration_response" "delete_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "DELETE"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_integration_response.any_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "get_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "GET"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "get_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "GET"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests]
}

resource "aws_api_gateway_method_response" "get_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "GET"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses]
}

resource "aws_api_gateway_integration_response" "get_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "GET"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "head_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "HEAD"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "head_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "HEAD"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests]
}

resource "aws_api_gateway_method_response" "head_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "HEAD"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses]
}

resource "aws_api_gateway_integration_response" "head_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "HEAD"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses, aws_api_gateway_integration_response.get_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "options_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "OPTIONS"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "options_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "OPTIONS"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests]
}

resource "aws_api_gateway_method_response" "options_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "OPTIONS"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses]
}

resource "aws_api_gateway_integration_response" "options_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "OPTIONS"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses, aws_api_gateway_integration_response.get_integration_responses, aws_api_gateway_integration_response.head_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "patch_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "PATCH"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "patch_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "PATCH"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests]
}

resource "aws_api_gateway_method_response" "patch_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "PATCH"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses]
}

resource "aws_api_gateway_integration_response" "patch_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "PATCH"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_integration.patch_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_method_response.patch_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses, aws_api_gateway_integration_response.get_integration_responses, aws_api_gateway_integration_response.head_integration_responses, aws_api_gateway_integration_response.options_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "post_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "POST"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "post_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "POST"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_integration.patch_integration_requests]
}

resource "aws_api_gateway_method_response" "post_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "POST"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_method_response.patch_method_responses]
}

resource "aws_api_gateway_integration_response" "post_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "POST"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_integration.patch_integration_requests, aws_api_gateway_integration.post_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_method_response.patch_method_responses, aws_api_gateway_method_response.post_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses, aws_api_gateway_integration_response.get_integration_responses, aws_api_gateway_integration_response.head_integration_responses, aws_api_gateway_integration_response.options_integration_responses, aws_api_gateway_integration_response.patch_integration_responses]
}# Method Request
resource "aws_api_gateway_method" "put_method_requests" {
  for_each             = {for key, value in local.method_requests: key => value if value.method == "PUT"}
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  http_method          = each.value.method
  authorization        = each.value.authorization
  authorizer_id        = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.authorizer[each.value.authorizer_id].id : each.value.authorizer_id
  authorization_scopes = each.value.authorization_scopes
  api_key_required     = each.value.api_key_required
  request_models       = each.value.request_models
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_parameters   = each.value.request_parameters == null ? {} : merge(var.method_request_default.request_parameters, each.value.request_parameters)
  depends_on           = [aws_cloudformation_stack.resources, aws_api_gateway_authorizer.authorizer, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests]
}

# Integration Request
resource "aws_api_gateway_integration" "put_integration_requests" {
  for_each                = {for key, value in local.integration_requests: key => value if value.method == "PUT"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp())) //we have to wait until api gateway updates.  if we use data resource with depends then resources are destroyed wiht every apply :( Timestamp forces tf to evaluate value during apply, rather than plan.
  http_method             = each.value.method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  connection_type         = each.value.connection_type
  connection_id           = each.value.connection_id
  uri                     = each.value.uri
  credentials             = each.value.credentials
  request_templates       = each.value.request_templates
  request_parameters      = each.value.request_parameters
  passthrough_behavior    = each.value.passthrough_behavior
  cache_key_parameters    = each.value.cache_key_parameters
  cache_namespace         = each.value.cache_namespace
  content_handling        = each.value.content_handling
  timeout_milliseconds    = each.value.timeout_milliseconds

  depends_on = [aws_cloudformation_stack.resources, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_method.put_method_requests, aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_integration.patch_integration_requests, aws_api_gateway_integration.post_integration_requests]
}

resource "aws_api_gateway_method_response" "put_method_responses" {
  for_each            = {for key, value in local.method_responses: key => value if value.method == "PUT"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
  depends_on          = [aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_method.put_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_method_response.patch_method_responses, aws_api_gateway_method_response.post_method_responses]
}

resource "aws_api_gateway_integration_response" "put_integration_responses" {
  for_each            = {for key, value in local.integration_responses: key => value if value.method == "PUT"}
  resource_id         = lookup(aws_cloudformation_stack.resources.outputs, md5(each.value.path), formatdate("HHmmss", timestamp()))
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  http_method         = each.value.method
  status_code         = each.value.status_code
  selection_pattern   = each.value.selection_pattern
  response_templates  = each.value.response_templates
  response_parameters = each.value.response_parameters
  content_handling    = each.value.content_handling
  depends_on          = [aws_api_gateway_integration.any_integration_requests, aws_api_gateway_integration.delete_integration_requests, aws_api_gateway_integration.get_integration_requests, aws_api_gateway_integration.head_integration_requests, aws_api_gateway_integration.options_integration_requests, aws_api_gateway_integration.patch_integration_requests, aws_api_gateway_integration.post_integration_requests, aws_api_gateway_integration.put_integration_requests, aws_api_gateway_method.any_method_requests, aws_api_gateway_method.delete_method_requests, aws_api_gateway_method.get_method_requests, aws_api_gateway_method.head_method_requests, aws_api_gateway_method.options_method_requests, aws_api_gateway_method.patch_method_requests, aws_api_gateway_method.post_method_requests, aws_api_gateway_method.put_method_requests, aws_api_gateway_method_response.any_method_responses, aws_api_gateway_method_response.delete_method_responses, aws_api_gateway_method_response.get_method_responses, aws_api_gateway_method_response.head_method_responses, aws_api_gateway_method_response.options_method_responses, aws_api_gateway_method_response.patch_method_responses, aws_api_gateway_method_response.post_method_responses, aws_api_gateway_method_response.put_method_responses, aws_api_gateway_integration_response.any_integration_responses, aws_api_gateway_integration_response.delete_integration_responses, aws_api_gateway_integration_response.get_integration_responses, aws_api_gateway_integration_response.head_integration_responses, aws_api_gateway_integration_response.options_integration_responses, aws_api_gateway_integration_response.patch_integration_responses, aws_api_gateway_integration_response.post_integration_responses]
}
