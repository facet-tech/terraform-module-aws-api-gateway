### terraform-module-aws-api-gateway
A Terraform module for creating aws api gateway dynamically.  Creates rest api, authorizer, methods and lambda integratyion, and stages.

### Code Example
```
module "api_gateway" {
  source              = "git@github.com:facets-io/terraform-module-aws-api-gateway.git?ref=0.0.2"
  name                = "my-api-gateway"
  environment         = "dev"
  description         = "This is my API"
  ip_whitelist        = "0.0.0.0/0"
  versioned_directory = "."
  deploy_live_stage   = true

  authorizers = [
    {
      name          = "embed-id"
      provider_arns = "arn:aws:cognito-idp:us-west-2:527490985582:my-user-pool/us-west-2_48d8d388"
    }]

  method_default = {
    method               = module.api_gateway.constants.GET
    authorization        = "COGNITO_USER_POOLS"
    authorizer_id        = "real-time-service-embed-id-my-authorizer"
    authorization_scopes = "MyScope/Scope"
    api_key_required     = false
    request_models       = {}
    request_validator_id = ""
    request_parameters   = {
      "method.request.header.my_authentication_header" = true
    }
  }

  endpoints = [
    {
      path    = "/authentication_token"
      methods = [
        {
          method               = module.api_gateway.constants.POST
          integration          = {
            uri                  = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:0000000000:function:my-function-1/invocations"
            passthrough_behavior = "WHEN_NO_MATCH"
            request_templates    = null
          }
          authorization        = "NONE"
          authorizer_id        = ""
          authorization_scopes = []
          request_parameters   = null
        }
      ]
    },
    {
      path    = "/path1/endpoint1"
      methods = [
        {
          method             = module.api_gateway.constants.GET
          integration        = {
            uri               = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:0000000000:function:my-function-2/invocations"
            request_templates = {
              "application/json" = "{\"param_1\":\"$input.params('param_1')\"}"
            }
          }
          request_parameters = {
            "method.request.querystring.param_1" = true
            "method.request.querystring.param_2" = true
          }          
        }
      ]
    }
  ]
}
```

## Providers

| Name | Version |
|------|---------|
| aws | 2.47.0 |
| external | 1.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| authorizers | n/a | `any` | n/a | yes |
| binary\_media\_types | n/a | `list(string)` | n/a | yes |
| body | n/a | `string` | n/a | yes |
| description | n/a | `string` | n/a | yes |
| endpoint\_configuration\_vpc\_endpoint\_ids | n/a | `list(string)` | n/a | yes |
| endpoints | n/a | `any` | n/a | yes |
| environment | n/a | `string` | n/a | yes |
| lambda\_permission\_event\_source\_token | (Optional) The Event Source Token to validate. Used with Alexa Skills. | `string` | n/a | yes |
| lambda\_permission\_qualifier | (Optional) Query parameter to specify function version or alias name. The permission will then apply to the specific qualified ARN. e.g. arn:aws:lambda:aws-region:acct-id:function:function-name:2 | `string` | n/a | yes |
| lambda\_permission\_source\_account | (Optional) This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner. | `string` | n/a | yes |
| lambda\_permission\_source\_arn | (Optional) When granting Amazon S3 or CloudWatch Events permission to invoke your function, you should specify this field with the Amazon Resource Name (ARN) for the S3 Bucket or CloudWatch Events Rule as its value. This ensures that only events generated from the specified bucket or rule can invoke the function. API Gateway ARNs have a unique structure described here. | `string` | n/a | yes |
| name | n/a | `string` | n/a | yes |
| versioned\_directory | If set, hash all files in directory to generate version number.  If hash changes terraform will redploy the api gateway stages (deployment). | `any` | n/a | yes |
| api\_key\_source | n/a | `string` | `"HEADER"` | no |
| authorizer\_default | n/a | <pre>object({<br>    authorizer_uri                   = string<br>    authorizer_credentials           = string<br>    authorizer_result_ttl_in_seconds = number<br>    identity_source                  = string<br>    type                             = string<br>    identity_validation_expression   = string<br>  })</pre> | <pre>{<br>  "authorizer_credentials": "",<br>  "authorizer_result_ttl_in_seconds": 300,<br>  "authorizer_uri": "",<br>  "identity_source": "method.request.header.Authentication",<br>  "identity_validation_expression": "",<br>  "type": "COGNITO_USER_POOLS"<br>}</pre> | no |
| aws\_api\_gateway\_stage\_default | n/a | <pre>object({<br>    stage_name            = string<br>    access_log_settings   = object({<br>      destination_arn = string<br>      format          = string<br>    })<br>    cache_cluster_enabled = bool<br>    cache_cluster_size    = number<br>    description           = string<br>    documentation_version = number<br>    variables             = map(string)<br>    xray_tracing_enabled  = bool<br>  })</pre> | <pre>{<br>  "access_log_settings": {<br>    "destination_arn": null,<br>    "format": null<br>  },<br>  "cache_cluster_enabled": false,<br>  "cache_cluster_size": 0.5,<br>  "description": "test",<br>  "documentation_version": null,<br>  "stage_name": "live",<br>  "variables": {},<br>  "xray_tracing_enabled": false<br>}</pre> | no |
| constants | n/a | <pre>object({<br>    GET    = string<br>    PUT    = string<br>    POST   = string<br>    DELETE = string<br>    HEAD   = string<br>    PATCH  = string<br>  })</pre> | <pre>{<br>  "DELETE": "DELETE",<br>  "GET": "GET",<br>  "HEAD": "HEAD",<br>  "PATCH": "PATCH",<br>  "POST": "POST",<br>  "PUT": "PUT"<br>}</pre> | no |
| deploy\_live\_stage | n/a | `bool` | `false` | no |
| deploy\_test\_stage | n/a | `bool` | `true` | no |
| endpoint\_configuration\_types | n/a | `list(string)` | <pre>[<br>  "REGIONAL"<br>]</pre> | no |
| force\_deploy\_live\_stage | n/a | `bool` | `false` | no |
| force\_deploy\_test\_stage | n/a | `bool` | `false` | no |
| integration\_default | n/a | <pre>object({<br>    integration_http_method = string<br>    type                    = string<br>    connection_type         = string<br>    connection_id           = string<br>    credentials             = string<br>    request_templates       = map(string)<br>    request_parameters      = map(string)<br>    passthrough_behavior    = string<br>    cache_key_parameters    = list(string)<br>    cache_namespace         = string<br>    content_handling        = string<br>    timeout_milliseconds    = number<br>    uri                     = string<br>  })</pre> | <pre>{<br>  "cache_key_parameters": [],<br>  "cache_namespace": "",<br>  "connection_id": "",<br>  "connection_type": "INTERNET",<br>  "content_handling": "CONVERT_TO_TEXT",<br>  "credentials": "",<br>  "integration_http_method": "POST",<br>  "passthrough_behavior": "WHEN_NO_TEMPLATES",<br>  "request_parameters": {},<br>  "request_templates": {<br>    "application/json": ""<br>  },<br>  "timeout_milliseconds": "29000",<br>  "type": "AWS_PROXY",<br>  "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:696666127573:function:CognitoAuth/invocations"<br>}</pre> | no |
| ip\_whitelist | n/a | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| lambda\_permission\_action | (Required if assigning a resource policy) The AWS Lambda action you want to allow in this statement. (e.g. lambda:InvokeFunction) | `string` | `"lambda:InvokeFunction"` | no |
| lambda\_permission\_principal | (Required if assigning a resource policy) The principal who is getting this permission. e.g. s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com. | `string` | `"apigateway.amazonaws.com"` | no |
| lambda\_permission\_statement\_id | (Optional) A unique statement identifier. By default generated by Terraform. | `string` | `"AllowInvokeFromApiGateway"` | no |
| live\_stage\_name | n/a | `string` | `"live"` | no |
| method\_default | n/a | <pre>object({<br>    method               = string<br>    authorization        = string<br>    authorizer_id        = string<br>    authorization_scopes = list(string)<br>    api_key_required     = bool<br>    request_models       = map(string)<br>    request_validator_id = string<br>    request_parameters   = map(string)<br>  })</pre> | <pre>{<br>  "api_key_required": false,<br>  "authorization": "NONE",<br>  "authorization_scopes": [],<br>  "authorizer_id": null,<br>  "method": "GET",<br>  "request_models": {},<br>  "request_parameters": {},<br>  "request_validator_id": ""<br>}</pre> | no |
| minimum\_compression\_size | n/a | `number` | `2048` | no |
| response\_default | n/a | <pre>map(object({<br>    status_code         = number<br>    response_models     = map(string)<br>    response_parameters = map(string)<br>  }))</pre> | <pre>{<br>  "200": {<br>    "response_models": {<br>      "application/json": "Empty"<br>    },<br>    "response_parameters": {},<br>    "status_code": "200"<br>  },<br>  "500": {<br>    "response_models": {<br>      "application/json": "Error"<br>    },<br>    "response_parameters": null,<br>    "status_code": "500"<br>  }<br>}</pre> | no |
| response\_intergration\_default | n/a | <pre>map(object({<br>    selection_pattern   = string<br>    response_templates  = map(string)<br>    response_parameters = map(string)<br>    content_handling    = string<br>  }))</pre> | <pre>{<br>  "200": {<br>    "content_handling": null,<br>    "response_parameters": {},<br>    "response_templates": {<br>      "application/json": ""<br>    },<br>    "selection_pattern": ""<br>  },<br>  "500": {<br>    "content_handling": null,<br>    "response_parameters": {},<br>    "response_templates": {<br>      "application/json": ""<br>    },<br>    "selection_pattern": "Error"<br>  }<br>}</pre> | no |
| stages | n/a | `list(any)` | <pre>[<br>  {<br>    "stage_name": "live"<br>  },<br>  {<br>    "stage_name": "dude"<br>  }<br>]</pre> | no |
| tags | n/a | `map(string)` | `{}` | no |
| test\_stage\_name | n/a | `string` | `"test"` | no |

## Outputs

| Name | Description |
|------|-------------|
| constants | n/a |
| endpoints | n/a |
| rest\_api | n/a |
| rest\_api\_execution\_arn | n/a |
| tags | n/a |

