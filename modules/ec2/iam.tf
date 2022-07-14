resource "aws_iam_instance_profile" "profile" {
  name = var.instance_profile_name
  role = var.role
}
