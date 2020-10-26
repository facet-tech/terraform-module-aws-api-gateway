resource "aws_api_gateway_request_validator" "validator" {
  name                        = "${var.name}-${var.environment}"
  rest_api_id                 = aws_api_gateway_rest_api.rest_api.id
  validate_request_body       = true
  validate_request_parameters = true
}