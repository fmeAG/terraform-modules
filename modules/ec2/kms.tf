resource "aws_kms_key" "key" {
  count = var.kms_key_id == null && !var.no_kms ? 1 : 0
  description             = "KMS key for ${var.server_name}"
  enable_key_rotation     = true
  tags=merge(var.default_tags,
    {
        Name = "TfHostKey ${var.default_tags.project_name} ${var.default_tags.stage}"
        Purpose = "Encryption of root volume of ${var.server_name}"
    }
  )
 policy = <<EOF
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

