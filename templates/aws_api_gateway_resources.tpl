Resources:
%{ for part in path_parts_map ~}
%{ if part.path_part != "" }
  ${part.path_hash}:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: ${aws_api_gateway_rest_api_id}
      ParentId: %{ if part.path_parent == "" }${aws_api_gateway_rest_api_root_resource_id}%{ else }!Ref ${part.path_parent_hash}%{ endif }
      PathPart: ${part.path_part}
%{ endif }
%{ endfor ~}

Outputs:
%{ for part in path_parts_map ~}
%{ if part.path_part != "" }
  ${part.path_hash}:
    Value: !Ref ${part.path_hash}
%{ endif }
%{ endfor ~}