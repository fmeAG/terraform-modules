resource "aws_lb" "nlb" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnets
  enable_cross_zone_load_balancing = var.cross_zone_lb
  tags=merge(var.default_tags,
  {
  Name = var.name
  }
  )
}
resource "aws_lb_listener" "list" {
  for_each=var.forward_listeners
  load_balancer_arn = aws_lb.nlb.arn
  port              = jsondecode(each.value).port
  protocol          = lookup(jsondecode(each.value),"protocol",null)
  ssl_policy = lookup(jsondecode(each.value),"ssl_policy",null)
  certificate_arn = lookup(jsondecode(each.value),"certificate_arn",null)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }
  depends_on=[aws_lb.nlb]
}
resource "aws_lb_target_group" "tg" {
  for_each=var.forward_listeners
  name     = lookup(jsondecode(each.value),"name",null)
  name_prefix = lookup(jsondecode(each.value),"name_prefix",null)
  port     = lookup(jsondecode(each.value),"tg_port",null)
  protocol = lookup(jsondecode(each.value),"tg_protocol",null)
  deregistration_delay = lookup(jsondecode(each.value),"deregistration_delay",null)
  slow_start = lookup(jsondecode(each.value),"slow_start",null)
  proxy_protocol_v2 = lookup(jsondecode(each.value),"proxy_protocol_v2",null)
  vpc_id   = var.vpc_id
  target_type = lookup(jsondecode(each.value),"target_type",null)
  dynamic health_check {
	for_each = jsondecode(each.value).health_check
	content {
		enabled = lookup(health_check.value, "enabled", null)
		interval = lookup(health_check.value, "interval", null)
    protocol = lookup(health_check.value, "protocol", null)
		port = lookup(health_check.value, "port", null)
    path = lookup(health_check.value, "path", null)
    matcher = lookup(health_check.value, "matcher", null)
    healthy_threshold = health_check.value.healthy_threshold
    unhealthy_threshold =  health_check.value.unhealthy_threshold
	}
  }
  depends_on=[aws_lb.nlb]
  tags=merge(var.default_tags,
  {
  Name = var.name
  })
}

