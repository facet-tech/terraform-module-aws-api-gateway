locals {
  create_custom_domain         = var.create_custom_domain ? 1 : 0
  nonprod_domain_part          = var.is_prod ? "" : "nonprod."
  domain_zone_name             = var.create_custom_domain ? data.aws_route53_zone.zone[0].name : ""
  route53_live_full_url        = "${var.route53_record_name}.${local.domain_zone_name}"
  route53_test_full_url        = "test-${var.route53_record_name}.${local.domain_zone_name}"
  route53_live_origin_full_url = "origin-${local.route53_live_full_url}"
  route53_test_origin_full_url = "origin-${local.route53_test_full_url}"
  regional_certificate_arn     = contains(var.endpoint_configuration_types, "REGIONAL") ? var.certificate_arn : null
  edge_certificate_arn         = contains(var.endpoint_configuration_types, "EDGE") ? var.certificate_arn : null
}

data "aws_route53_zone" "zone" {
  count        = local.create_custom_domain
  zone_id      = var.route53_record_zone_id
  private_zone = false
}

module "live_test_certificate" {
  create_certificate                    = var.create_custom_domain
  source                                = "git@github.com:facets-io/terraform-module-aws-acm-certificate.git?ref=0.0.5"
  domain_name                           = local.route53_live_full_url
  subject_alternative_names             = [local.route53_test_full_url]
  route53_hosted_zone_id                = var.route53_record_zone_id
}
resource "null_resource" "sleep_after_provisioning_certificate" {
  count      = local.create_custom_domain
  provisioner "local-exec" {
    command = "sleep 60"
  }
  triggers   = {
    certificate_arn = module.live_test_certificate.certificate.arn
  }
  depends_on = [module.live_test_certificate.certificate]
}
resource "aws_api_gateway_domain_name" "live" {
  count                     = local.create_custom_domain
  domain_name               = trim(local.route53_live_full_url, ".")
  security_policy           = "TLS_1_2"
  tags                      = var.tags
  certificate_arn           = local.edge_certificate_arn
  regional_certificate_arn  = module.live_test_certificate.certificate.arn
  certificate_body          = var.certificate_body
  certificate_chain         = var.certificate_chain
  certificate_name          = var.certificate_name
  certificate_private_key   = var.certificate_private_key
  regional_certificate_name = var.regional_certificate_name
  endpoint_configuration {
    types = var.endpoint_configuration_types
  }
  depends_on                = [module.live_test_certificate, null_resource.sleep_after_provisioning_certificate]
}

resource "aws_api_gateway_domain_name" "test" {
  count                     = local.create_custom_domain
  domain_name               = trim(local.route53_test_full_url, ".")
  security_policy           = "TLS_1_2"
  tags                      = var.tags
  certificate_arn           = local.edge_certificate_arn
  certificate_body          = var.certificate_body
  certificate_chain         = var.certificate_chain
  certificate_name          = var.certificate_name
  certificate_private_key   = var.certificate_private_key
  regional_certificate_arn  = module.live_test_certificate.certificate.arn
  regional_certificate_name = var.regional_certificate_name
  endpoint_configuration {
    types = var.endpoint_configuration_types
  }
  depends_on                = [module.live_test_certificate, null_resource.sleep_after_provisioning_certificate]
}


resource "aws_route53_record" "live_origin" {
  count   = local.create_custom_domain
  name    = local.route53_live_origin_full_url
  type    = "A"
  zone_id = var.route53_record_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.live[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.live[0].regional_zone_id
  }
}

resource "aws_route53_record" "live" {
  count   = local.create_custom_domain
  name    = local.route53_live_full_url
  type    = "A"
  zone_id = var.route53_record_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_route53_record.live_origin[0].name
    zone_id                = aws_route53_record.live_origin[0].zone_id
  }
}


resource "aws_route53_record" "test_origin" {
  count   = local.create_custom_domain
  name    = local.route53_test_origin_full_url
  type    = "A"
  zone_id = var.route53_record_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.test[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.test[0].regional_zone_id
  }
}

resource "aws_route53_record" "test" {
  count   = local.create_custom_domain
  name    = local.route53_test_full_url
  type    = "A"
  zone_id = var.route53_record_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_route53_record.test_origin[0].name
    zone_id                = aws_route53_record.test_origin[0].zone_id
  }
}


resource "aws_api_gateway_base_path_mapping" "live" {
  count       = local.create_custom_domain
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.live.stage_name
  domain_name = aws_api_gateway_domain_name.live[0].domain_name
  base_path   = ""
}
resource "aws_api_gateway_base_path_mapping" "test" {
  count       = local.create_custom_domain
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.test.stage_name
  domain_name = aws_api_gateway_domain_name.test[0].domain_name
  base_path   = ""
}

# Everything below can be removed
#resource "aws_acm_certificate" "certificate" {
#  count                     = local.create_custom_domain
#  domain_name               = local.certificate_domain_name
#  subject_alternative_names = var.certificate_subject_alternative_names
#  validation_method         = local.certificate_validation_method
#  options {
#    certificate_transparency_logging_preference = var.certificate_options_certificate_transparency_logging_preference
#  }
#  private_key               = var.certificate_private_key
#  certificate_body          = var.certificate_certificate_body
#  certificate_chain         = var.certificate_certificate_chain
#}
#
#resource "aws_route53_record" "certificate_validation_record" {
#  count   = local.create_custom_domain
#  name    = aws_acm_certificate.certificate[0].domain_validation_options.0.resource_record_name
#  type    = aws_acm_certificate.certificate[0].domain_validation_options.0.resource_record_type
#  zone_id = aws_route53_zone.domain[0].zone_id
#  records = [aws_acm_certificate.certificate[0].domain_validation_options.0.resource_record_value]
#  ttl     = var.certificate_validation_record_ttl
#}
#
#resource "aws_acm_certificate_validation" "certificate_validation" {
#  count                   = local.create_custom_domain
#  certificate_arn         = aws_acm_certificate.certificate[0].arn
#  validation_record_fqdns = toset([aws_route53_record.certificate_validation_record[0].fqdn])
#}

// Imperva Setup
/*
resource "incapsula_site" "test" {

  domain                 = local.route53_test_full_url
  account_id             = var.imperva_account_id
  send_site_setup_emails = var.imperva_send_site_setup_emails
  site_ip                = local.route53_test_origin_full_url
  force_ssl              = "true"
  log_level              = var.imperva_log_level
  logs_account_id        = var.imperva_logs_account_id
}

resource "incapsula_site" "test" {
  domain                 = local.route53_live_full_url
  account_id             = var.imperva_account_id
  send_site_setup_emails = var.imperva_send_site_setup_emails
  site_ip                = local.route53_live_origin_full_url
  force_ssl              = "true"
  log_level              = var.imperva_log_level
  logs_account_id        = var.imperva_logs_account_id
}
*/