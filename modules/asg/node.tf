resource "aws_launch_configuration" "node" {
  associate_public_ip_address = var.make_public
  iam_instance_profile        = var.iam_role == null ? null : length(aws_iam_instance_profile.asg) > 0 ? aws_iam_instance_profile.asg.0.name : null
  image_id                    = var.ami
  instance_type               = var.node_type
  name_prefix                 = var.cluster_name
  security_groups             = var.sg_ids
  user_data_base64            = data.template_cloudinit_config.config.rendered
  key_name                    = var.ssh_key_name
  spot_price                  = var.spot_price
  root_block_device {
    volume_type = "gp2"
    volume_size = var.node_volume_size
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node" {
  launch_configuration = aws_launch_configuration.node.id
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  name                 = var.cluster_name
  vpc_zone_identifier  = var.subnet_ids
  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
resource "aws_autoscaling_policy" "asp-1" {
  name                   = "autoscaling-${var.cluster_name}"
  policy_type                    =  "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
        disable_scale_in = true
    target_value = 70.0
  }
  autoscaling_group_name = aws_autoscaling_group.node.name
}
locals {
	asg_tags = merge(var.default_tags,
  {
  InspectorScan = var.use_inspector==true ? true : false
  Name = "${var.cluster_name}-node"
  },var.additional_tags_ec2
  )
}
