data "aws_caller_identity" "current" {}

data "tls_certificate" "hvs_certificate" {
  url = "https://${var.hvs_openid_connect_url}"
}

resource "aws_iam_openid_connect_provider" "hvs" {
  url             = "https://${var.hvs_openid_connect_url}"
  client_id_list  = [var.hvs_aws_audience]
  thumbprint_list = [data.tls_certificate.hvs_certificate.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "hvs_role_identity" {
  name = "hvs_role_identity"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "${aws_iam_openid_connect_provider.hvs.arn}"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "${var.hvs_openid_connect_url}:aud": [
           "${one(aws_iam_openid_connect_provider.hvs.client_id_list)}"
         ]
       }
     }
   }
 ]
}
EOF
}

resource "aws_iam_role" "hvs_role_dynamic_secrets" {
  name = "hvs_role_dynamic_secrets"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "AWS": "${aws_iam_role.hvs_role_identity.arn}"
    },
    "Action": "sts:AssumeRole",
    "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_policy" "hvs_dynamic_secrets_policy" {
  name        = "hvs-policy"
  description = "HVS Policy"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "*"
      ],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_policy_attachment" {
  role       = aws_iam_role.hvs_role_dynamic_secrets.name
  policy_arn = aws_iam_policy.hvs_dynamic_secrets_policy.arn
}
