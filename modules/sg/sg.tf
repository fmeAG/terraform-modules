resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags = var.tags
}
resource "aws_security_group_rule" "sgr" {
	for_each = var.rules
	security_group_id = aws_security_group.sg.id
	type = jsondecode(each.value).type
	from_port = jsondecode(each.value).from_port
	to_port = jsondecode(each.value).to_port
	protocol = jsondecode(each.value).protocol
	cidr_blocks = lookup(jsondecode(each.value), "cidr_blocks", null)
	source_security_group_id = lookup(jsondecode(each.value), "source_security_group_id", null) == null ? null : (lookup(jsondecode(each.value),"source_security_group_id" , null) == "self" ?  null : lookup(jsondecode(each.value),"source_security_group_id" , null) )
	self = lookup(jsondecode(each.value),"source_security_group_id", null) == "self" ? true : null
}
