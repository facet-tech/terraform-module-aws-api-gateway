variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable binary_media_types {
  type    = list(string)
  default = null
}

variable minimum_compression_size {
  type    = number
  default = 2048
}

variable body {
  type    = string
  default = null
}

variable api_key_source {
  type    = string
  default = "HEADER"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "endpoint_configuration_vpc_endpoint_ids" {
  type    = list(string)
  default = null
}

variable "ip_whitelist" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "authorizers" {
  type    = any
  default = []
}

variable "authorizer_default" {
  type = object({
    authorizer_uri                   = string
    authorizer_credentials           = string
    authorizer_result_ttl_in_seconds = number
    identity_source                  = string
    type                             = string
    identity_validation_expression   = string
  })

  default = {
    authorizer_uri                   = ""
    authorizer_credentials           = ""
    authorizer_result_ttl_in_seconds = 300
    identity_source                  = "method.request.header.Authentication"
    type                             = "COGNITO_USER_POOLS"
    identity_validation_expression   = ""
  }
}

variable "stages" {
  type    = list(any)
  default = [{
    stage_name = "live"
  }, {
    stage_name = "dude"
  }]
}

variable "aws_api_gateway_stage_default" {
  type = object({
    stage_name            = string
    access_log_settings   = object({
      destination_arn = string
      format          = string
    })
    cache_cluster_enabled = bool
    cache_cluster_size    = number
    description           = string
    documentation_version = number
    variables             = map(string)
    xray_tracing_enabled  = bool
  })

  default = {
    stage_name            = "live"
    access_log_settings   = {
      destination_arn = null
      format          = null
    }
    cache_cluster_enabled = false
    cache_cluster_size    = 0.5
    description           = "test"
    documentation_version = null
    variables             = {}
    xray_tracing_enabled  = false
  }
}

variable endpoints {
  type = any
}

variable "method_default" {
  type = object({
    method               = string
    authorization        = string
    authorizer_id        = string
    authorization_scopes = list(string)
    api_key_required     = bool
    request_models       = map(string)
    request_validator_id = string
    request_parameters   = map(string)
  })

  //Empty string instead of null because merge removes empty string from list
  default = {
    method               = "GET"
    authorization        = "NONE"
    authorizer_id        = null
    authorization_scopes = []
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {}
  }
}

variable "integration_default" {
  type = object({
    integration_http_method = string
    type                    = string
    connection_type         = string
    connection_id           = string
    credentials             = string
    request_templates       = map(string)
    request_parameters      = map(string)
    passthrough_behavior    = string
    cache_key_parameters    = list(string)
    cache_namespace         = string
    content_handling        = string
    timeout_milliseconds    = number
    uri                     = string
  })

  default = {
    type                    = "AWS_PROXY"
    integration_http_method = "POST"
    connection_type         = "INTERNET"
    connection_id           = ""
    credentials             = ""
    request_templates       = {
      "application/json" = ""
    }
    request_parameters      = {}
    passthrough_behavior    = "WHEN_NO_TEMPLATES"
    cache_key_parameters    = []
    cache_namespace         = ""
    content_handling        = "CONVERT_TO_TEXT"
    timeout_milliseconds    = "29000"
    uri                     = "" #"arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:696666127573:function:CognitoAuth/invocations"
  }
}


variable "response_default" {
  type = map(object({
    status_code         = number
    response_models     = map(string)
    response_parameters = map(string)
  }))

  default = {
    500 = {
      status_code         = "500"
      response_models     = {
        "application/json" = "Error"
      }
      response_parameters = null
    },
    200 = {
      status_code         = "200"
      response_models     = {
        "application/json" = "Empty"
      }
      response_parameters = {}
    }
  }
}

variable "response_intergration_default" {
  type    = map(object({
    selection_pattern   = string
    response_templates  = map(string)
    response_parameters = map(string)
    content_handling    = string
  }))
  default = {
    200 = {
      selection_pattern   = ""
      response_templates  = {
        "application/json" = ""
      }
      response_parameters = {}
      content_handling    = null
    },
    500 = {
      selection_pattern   = "Error"
      response_templates  = {
        "application/json" = ""
      }
      response_parameters = {}
      content_handling    = null
    }
  }
}

variable "constants" {
  type    = object({
    GET    = string
    PUT    = string
    POST   = string
    DELETE = string
    HEAD   = string
    PATCH  = string
  })
  default = {
    GET    = "GET"
    PUT    = "PUT"
    POST   = "POST"
    DELETE = "DELETE"
    HEAD   = "HEAD"
    PATCH  = "PATCH"
    ANY    = "ANY"
  }
}


variable "lambda_permission_action" {
  type        = string
  description = "(Required if assigning a resource policy) The AWS Lambda action you want to allow in this statement. (e.g. lambda:InvokeFunction)"
  default     = "lambda:InvokeFunction"
}
variable "lambda_permission_event_source_token" {
  type        = string
  description = "(Optional) The Event Source Token to validate. Used with Alexa Skills."
  default     = null
}
variable "lambda_permission_principal" {
  type        = string
  description = "(Required if assigning a resource policy) The principal who is getting this permission. e.g. s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com."
  default     = "apigateway.amazonaws.com"
}
variable "lambda_permission_source_account" {
  type        = string
  description = "(Optional) This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner."
  default     = null
}
variable "lambda_permission_source_arn" {
  type        = string
  description = "(Optional) When granting Amazon S3 or CloudWatch Events permission to invoke your function, you should specify this field with the Amazon Resource Name (ARN) for the S3 Bucket or CloudWatch Events Rule as its value. This ensures that only events generated from the specified bucket or rule can invoke the function. API Gateway ARNs have a unique structure described here."
  default     = null
}
variable "lambda_permission_statement_id_prefix" {
  type        = string
  description = "A statement identifier prefix. By default generated by Terraform."
  default     = "AllowInvokeFromApiGateway"
}

variable "versioned_directory" {
  description = "If set, hash all files in directory to generate version number.  If hash changes terraform will redploy the api gateway stages (deployment)."
  default     = null
}

variable "test_stage_name" {
  default = "test"
}

variable "live_stage_name" {
  default = "live"
}

variable "deploy_live_stage" {
  default = false
  type    = bool
}

variable "deploy_test_stage" {
  default = true
  type    = bool
}

variable "force_deploy_live_stage" {
  default = false
  type    = bool
}

variable "force_deploy_test_stage" {
  default = false
  type    = bool
}

# -------------------------------------------
#    Custom Domain Name Configurations
# -------------------------------------------
variable "create_custom_domain" {
  type        = bool
  description = "Should a custom domain name and route 53 entry (per stage) be created?"
  default     = "false"
}
variable "is_prod" {
  type        = bool
  description = "Is this a prod environment (ie. not staging, qa, dev, playground)?"
  default     = false
}
variable "endpoint_configuration_types" {
  type        = list(string)
  default     = ["REGIONAL"]
  description = "(Optional) A list of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE or REGIONAL. If unspecified, defaults to EDGE. Must be declared as REGIONAL in non-Commercial partitions. Refer to the documentation for more information on the difference between edge-optimized and regional APIs"
}
variable "security_policy" {
  type        = string
  description = "(Optional) The Transport Layer Security (TLS) version + cipher suite for this DomainName. The valid values are TLS_1_0 and TLS_1_2. Must be configured to perform drift detection."
  default     = "TLS_1_2"
}
variable "certificate_arn" {
  type        = string
  description = "(Optional) The ARN for an AWS-managed certificate. AWS Certificate Manager is the only supported source. Used when an edge-optimized domain or regional name is desired. Conflicts with certificate_name, certificate_body, certificate_chain, certificate_private_key, and regional_certificate_name."
  default     = null
}
variable "certificate_name" {
  type        = string
  description = "(Optional) The unique name to use when registering this certificate as an IAM server certificate. Conflicts with certificate_arn, regional_certificate_arn, and regional_certificate_name. Required if certificate_arn is not set."
  default     = null
}
variable "certificate_body" {
  type        = string
  description = "(Optional) The certificate issued for the domain name being registered, in PEM format. Only valid for EDGE endpoint configuration type. Conflicts with certificate_arn, regional_certificate_arn, and regional_certificate_name."
  default     = null
}
variable "certificate_chain" {
  type        = string
  description = "(Optional) The certificate for the CA that issued the certificate, along with any intermediate CA certificates required to create an unbroken chain to a certificate trusted by the intended API clients. Only valid for EDGE endpoint configuration type. Conflicts with certificate_arn, regional_certificate_arn, and regional_certificate_name."
  default     = null
}
variable "certificate_private_key" {
  type        = string
  description = "(Optional) The private key associated with the domain certificate given in certificate_body. Only valid for EDGE endpoint configuration type. Conflicts with certificate_arn, regional_certificate_arn, and regional_certificate_name."
  default     = null
}
variable "regional_certificate_name" {
  type        = string
  description = "(Optional) The user-friendly name of the certificate that will be used by regional endpoint for this domain name. Conflicts with certificate_arn, certificate_name, certificate_body, certificate_chain, and certificate_private_key."
  default     = null
}
variable "route53_record_zone_id" {
  type        = string
  description = "(Optional) The ID of the hosted zone to contain this record."
  default     = null
}
variable "route53_record_name" {
  type        = string
  description = "(Optional) The name of the record for the live stage. This should not include any environment info (ie. should look like 'real-time-services'). Default is drawn from the 'name' variable."
  default     = ""
}
variable "route53_record_set_identifier" {
  type        = string
  description = "(Optional) Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, or weighted routing policies documented below."
  default     = null
}
variable "route53_record_health_check_id" {
  type        = string
  description = "(Optional) The health check the record should be associated with."
  default     = null
}
variable "route53_record_allow_overwrite" {
  type        = string
  description = "(Optional) Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. false by default. This configuration is not recommended for most environments."
  default     = null
}
