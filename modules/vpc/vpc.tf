resource "aws_vpc" "project" {
  count = var.vpc_id == null ? 1 : 0
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = var.cidr_range
  tags = merge(var.default_tags,
{
	    "Name" = "VPC ${var.default_tags.project_name} ${var.default_tags.stage}"
})
}
resource "aws_subnet" "project" {
  for_each = var.private_subnet_cidrs
  availability_zone = data.aws_availability_zones.available.names[each.key]
  cidr_block        = each.value
  vpc_id            = aws_vpc.project.0.id
  tags = merge(var.default_tags,
{
            "Name" = "SN private ${var.default_tags.project_name} ${var.default_tags.stage}"
},var.private_subnet_tags)
}
resource "aws_subnet" "projectp" {
  for_each = var.public_subnet_cidrs
  availability_zone = data.aws_availability_zones.available.names[each.key]
  cidr_block        = each.value
  vpc_id            = aws_vpc.project.0.id
  tags = merge(var.default_tags,
{
            "Name" = "SN public ${var.default_tags.project_name} ${var.default_tags.stage}"
},var.public_subnet_tags)
}

resource "aws_internet_gateway" "project" {
  count = var.vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.project.0.id
    tags = merge(var.default_tags,
{
            "Name" = "IGW ${var.default_tags.project_name} ${var.default_tags.stage}"
})
}

resource "aws_route_table" "projectp" {
  count = var.vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.project.0.id
  tags = merge(var.default_tags,
{
            "Name" = "RT public ${var.default_tags.project_name} ${var.default_tags.stage}"
})
}
resource "aws_route" "projectp_default" {
  count                     = var.vpc_id == null ? 1 : 0
  route_table_id            = aws_route_table.projectp.0.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.project.0.id
}
resource "aws_route" "projectp_custom" {
  for_each                    = var.vpc_id == null ? var.custom_public_routes : []
  route_table_id              = aws_route_table.projectp.0.id
  destination_cidr_block      = lookup(jsondecode(each.value),"destination_cidr_block",null)
  destination_ipv6_cidr_block = lookup(jsondecode(each.value),"destination_ipv6_cidr_block",null)
  egress_only_gateway_id      = lookup(jsondecode(each.value),"egress_only_gateway_id",null)
  nat_gateway_id              = lookup(jsondecode(each.value),"nat_gateway_id",null)
  network_interface_id        = lookup(jsondecode(each.value),"network_interface_id",null)
  transit_gateway_id          = lookup(jsondecode(each.value),"transit_gateway_id",null)
  vpc_peering_connection_id   = lookup(jsondecode(each.value),"vpc_peering_connection_id",null)
  gateway_id                  = lookup(jsondecode(each.value),"gateway_id",null)
}

resource "aws_default_security_group" "default" {
  count = var.vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.project.0.id
}


resource "aws_route_table_association" "projectp" {
  count = var.vpc_id == null ?  length(aws_subnet.projectp) : 0
  subnet_id      = aws_subnet.projectp[count.index].id
  route_table_id = aws_route_table.projectp.0.id
}
resource "aws_route_table_association" "projectp2" {
  count = var.vpc_id == null && var.private2public ?  length(aws_subnet.project) : 0
  subnet_id      = aws_subnet.project[count.index].id
  route_table_id = aws_route_table.projectp.0.id
}

resource "aws_route_table" "project" {
  count = var.vpc_id == null ? 1 :0 
  vpc_id = aws_vpc.project.0.id
 tags = merge(var.default_tags,
{
            "Name" = "RT private ${var.default_tags.project_name} ${var.default_tags.stage}"
})
}
resource "aws_route" "project_nat" {
  count                     = var.use-nat && var.vpc_id == null ? 1 :0
  route_table_id            = aws_route_table.project.0.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat.0.id
}
resource "aws_route" "project_custom" {
  for_each                    = var.vpc_id == null ? var.custom_private_routes : []
  route_table_id              = aws_route_table.project.0.id
  destination_cidr_block      = lookup(jsondecode(each.value),"destination_cidr_block",null)
  destination_ipv6_cidr_block = lookup(jsondecode(each.value),"destination_ipv6_cidr_block",null)
  egress_only_gateway_id      = lookup(jsondecode(each.value),"egress_only_gateway_id",null)
  nat_gateway_id              = lookup(jsondecode(each.value),"nat_gateway_id",null)
  network_interface_id        = lookup(jsondecode(each.value),"network_interface_id",null)
  transit_gateway_id          = lookup(jsondecode(each.value),"transit_gateway_id",null)
  vpc_peering_connection_id   = lookup(jsondecode(each.value),"vpc_peering_connection_id",null)
  gateway_id                  = lookup(jsondecode(each.value),"gateway_id",null)
}

#######NAT Gateway
resource "aws_nat_gateway" "nat" {
  count = var.use-nat ==true && var.vpc_id == null ? 1 :0 
  allocation_id = aws_eip.nat.0.id
  subnet_id     = aws_subnet.projectp[var.nat-subnet].id
  tags = merge(var.default_tags,
{
            "Name" = "NAT ${var.default_tags.project_name} ${var.default_tags.stage}"
})
  depends_on = [aws_subnet.projectp]
}

resource "aws_eip" "nat" {
  count = var.use-nat == true && var.vpc_id == null ? 1 :0 
  vpc = true
   tags = merge(var.default_tags,
{
            "Name" = "EIP NAT ${var.default_tags.project_name} ${var.default_tags.stage}"
})
}

resource "aws_route_table_association" "project" {
  count = !var.private2public && var.vpc_id == null ? length(aws_subnet.project) : 0
  subnet_id      = aws_subnet.project[count.index].id
  route_table_id = aws_route_table.project.0.id
}
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  for_each   = var.vpc_id == null ? var.secondary_cidrs : []
  vpc_id     = aws_vpc.project.0.id
  cidr_block = each.value
}
