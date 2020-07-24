#############################################
###############INSTANCE PROFILES#############
#############################################
resource "aws_iam_instance_profile" "asg" {
  count = var.iam_role == null ? 0 : 1
  name  = var.instance_profile_name
  role  = var.iam_role
}

