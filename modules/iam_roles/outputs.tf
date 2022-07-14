output "arn" {
        value = var.role_arn == null ? (length(aws_iam_role.role) > 0 ? aws_iam_role.role.0.arn : "none") : var.role_arn
}
output "name" {
        value = var.role_name == null ? (length(aws_iam_role.role) > 0 ? aws_iam_role.role.0.name : "none") : var.role_name
}
output "arns_policies" {
	value = [
	for policy in aws_iam_policy.policy:
	policy.arn
]
}
output "arns_named_policies" {
        value = [
        for policy in aws_iam_policy.named_policy:
        policy.arn
]
}

output "role" {
  value = var.role_arn == null ? (length(aws_iam_role.role) > 0 ? aws_iam_role.role.0 : object({arn = "none"})) : object({arn = var.role_arn})
}
