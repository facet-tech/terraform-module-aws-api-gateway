resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.name}-${var.environment}"

  endpoint_configuration {
    types            = var.endpoint_configuration_types
    vpc_endpoint_ids = var.endpoint_configuration_vpc_endpoint_ids
  }

  binary_media_types       = var.binary_media_types
  minimum_compression_size = var.minimum_compression_size
  body                     = var.body

  policy = templatefile("${path.module}/templates/default_policy.tpl", {
    account_id   = data.aws_caller_identity.current_user.account_id
    region       = data.aws_region.current_user.name
    ip_whitelist = jsonencode(var.ip_whitelist)
  })

  api_key_source = var.api_key_source
  tags           = module.default_tags.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

data "aws_caller_identity" "current_user" {}

data "aws_region" "current_user" {}

module "default_tags" {
  source          = "git@github.com:facets-io/terraform-module-aws-tags-default.git?ref=0.0.1"
  additional_tags = var.tags
  environment     = var.environment
}
