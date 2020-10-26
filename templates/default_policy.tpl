{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${account_id}:root"
    },
    "Action": "execute-api:*",
    "Resource": "arn:aws:execute-api:${region}:${account_id}:*/*"
  },
  {
    "Effect": "Allow",
    "Principal": "*",
    "Action": "execute-api:Invoke",
    "Resource": "arn:aws:execute-api:${region}:${account_id}:*/*"
  },
  {
    "Effect": "Deny",
    "Principal": "*",
    "Action": "execute-api:Invoke",
    "Resource": "arn:aws:execute-api:${region}:${account_id}:*/*/*/private*",
    "Condition": {
      "NotIpAddress": {
        "aws:SourceIp": ${ip_whitelist}
      }
    }
  }
  ]
}