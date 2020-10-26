resource "aws_cloudformation_stack" "resources" {
  name          = "${var.name}-api-gateway-${var.environment}"
  template_body = templatefile("${path.module}/templates/aws_api_gateway_resources.tpl", {
    path_parts_map                            = local.path_parts_map
    aws_api_gateway_rest_api_id               = aws_api_gateway_rest_api.rest_api.id
    aws_api_gateway_rest_api_root_resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
    timeout_in_minutes = 10
  })
  lifecycle {
    ignore_changes = [tags]
  }
 // tags = module.default_tags.tags
}