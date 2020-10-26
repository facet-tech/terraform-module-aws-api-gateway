resource "aws_api_gateway_client_certificate" "certificate" {
  description = "${var.name}-${var.environment}"
  tags        = module.default_tags.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_api_gateway_deployment" "test_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  variables     = {
    version           = local.deploy_test_stage_version_hash
    forced_deployment = local.forced_deploy_test_stage_version
  }
  depends_on = [null_resource.method-delay]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_deployment" "live_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  variables     = {
    version           = local.deploy_live_stage_version_hash
    forced_deployment = local.forced_deploy_live_stage_version
  }
  depends_on = [
    aws_api_gateway_deployment.test_deployment,
    null_resource.method-delay
  ]
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  versioned_files_relative_path = setsubtract(
                                      setsubtract(
                                          fileset(var.versioned_directory, "**"),
                                          fileset(var.versioned_directory, "**/{.git,plugins}/**")
                                      ),
                                      fileset(var.versioned_directory, "**/{*-manifest,*.tfstate,*.tfstate*,modules.json,backend.tf}")
                                  )

  versioned_files_absolute_path = formatlist("${var.versioned_directory}/%s", local.versioned_files_relative_path)

  //Generates a hash of files in the versioned directory.
  versioned_files_hash_without_endpoints = sha1(join("", [
  for path in local.versioned_files_absolute_path:
  filebase64sha256(path)
  ]))
  // We also hash the endpoints variable to catch changes in lambda function version.
  versioned_files_hash = sha1(join("", [local.versioned_files_hash_without_endpoints, jsonencode(var.endpoints)]))

  deploy_test_stage_version_hash = var.deploy_test_stage || data.external.test_stage_old_version.result.version == "" ? local.versioned_files_hash : data.external.test_stage_old_version.result.version
  deploy_live_stage_version_hash = var.deploy_live_stage || data.external.live_stage_old_version.result.version == "" ? local.versioned_files_hash : data.external.live_stage_old_version.result.version
  forced_deploy_live_stage_version = var.force_deploy_live_stage ? uuid() : null
  forced_deploy_test_stage_version = var.force_deploy_test_stage ? uuid() : null
}

data "external" "live_stage_old_version" {
  program = [
    "bash",
    "${path.module}/scripts/get_stage_version.sh",
    aws_api_gateway_rest_api.rest_api.id,
    var.live_stage_name,
    data.aws_region.current_user.name]
}

data "external" "test_stage_old_version" {
  program = [
    "bash",
    "${path.module}/scripts/get_stage_version.sh",
    aws_api_gateway_rest_api.rest_api.id,
    var.test_stage_name,
    data.aws_region.current_user.name]
}

resource "aws_api_gateway_stage" "live" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.live_stage_name
  deployment_id = aws_api_gateway_deployment.live_deployment.id
  variables     = {
    version           = local.deploy_live_stage_version_hash
    forced_deployment = local.forced_deploy_live_stage_version
  }
  depends_on = [null_resource.method-delay]
}

resource "aws_api_gateway_stage" "test" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.test_stage_name
  deployment_id = aws_api_gateway_deployment.test_deployment.id
  variables     = {
    version           = local.deploy_test_stage_version_hash
    forced_deployment = local.forced_deploy_test_stage_version
  }
  depends_on = [aws_api_gateway_deployment.test_deployment, null_resource.method-delay]
}

resource "null_resource" "method-delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  triggers = {
    #always_wait = uuid()
    deploy_test_stage_version_hash = local.deploy_test_stage_version_hash
    deploy_live_stage_version_hash = local.deploy_live_stage_version_hash
    forced_deployment_test = local.forced_deploy_test_stage_version
    forced_deployment_live = local.forced_deploy_live_stage_version
  }
  depends_on = [aws_cloudformation_stack.resources]
}