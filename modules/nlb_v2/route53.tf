resource "aws_route53_record" "dns_set" {
  for_each = toset(jsondecode(lookup(var.dns,"zone_ids","[]")))
  zone_id = each.value
  name    = var.dns.name
  type    = "A"
  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
}

