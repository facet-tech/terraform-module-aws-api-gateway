{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeRoleFromApiGateway",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}