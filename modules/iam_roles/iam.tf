resource "aws_iam_role" "role" {
  count = var.role_arn == null ? 1 : 0
  name = var.role_name
  tags = var.default_tags
  max_session_duration = var.max_session_duration
  assume_role_policy = var.trust_policy == null ? (
<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": ${local.principal},
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
) : var.trust_policy
}

resource "aws_iam_policy" "policy" {
	for_each =  var.role_arn == null ? var.policies : var.fake_policies
	policy = each.value
}
resource "aws_iam_policy" "named_policy" {
        for_each =  var.role_arn == null ? var.named_policies : var.fake_named_policies
	name = each.key
        policy = each.value
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = aws_iam_policy.policy
  role      = aws_iam_role.role.0.name
  policy_arn = each.value.arn
}
resource "aws_iam_role_policy_attachment" "attach_named" {
  for_each = aws_iam_policy.named_policy
  role      = aws_iam_role.role.0.name
  policy_arn = each.value.arn
}
resource "aws_iam_role_policy_attachment" "attach_arns" {
  for_each = var.role_arn == null ? var.policy_arns : var.fake_policy_arns
  role      = aws_iam_role.role.0.name
  policy_arn = each.value
}
locals{
	principal = var.trust_policy == null ? (var.principal_json == null ? (length(var.aws_principals) == 0 ? 
<<EOF
{
        "Service" : "${var.service}"
}
EOF
: <<EOF
{
        "AWS" : ${jsonencode(var.aws_principals)}
}
EOF
) : var.principal_json
) : null
}
