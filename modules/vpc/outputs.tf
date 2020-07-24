output "vpc_id" {
        value = var.vpc_id == null ? (length(aws_vpc.project) > 0 ? aws_vpc.project.0.id : "none"): var.vpc_id
}

output "private_subnet_ids"{
        value = var.vpc_id == null ? [for subnet in aws_subnet.project: subnet.id] : keys(var.private_subnet_ids)
}

output "public_subnet_ids"{
        value = var.vpc_id == null ? [for subnet in aws_subnet.projectp: subnet.id] : keys(var.public_subnet_ids)
}
output "private_subnets"{
        value = var.vpc_id == null ? [for subnet in aws_subnet.project: subnet] : [
	for subnet in keys(var.private_subnet_ids):
	{
		"id" = subnet	
		"availability_zone" = var.private_subnet_ids[subnet]
	}
]
}

output "public_subnets"{
        value = var.vpc_id == null ? [for subnet in aws_subnet.projectp: subnet] : [
	for subnet in keys(var.public_subnet_ids):
        {
                "id" = subnet
                "availability_zone" = var.public_subnet_ids[subnet]
        }
]
}

output "vpc_cidr" {
        value = var.vpc_id == null ? (length(aws_vpc.project)>0 ? aws_vpc.project.0.cidr_block : "none") : var.vpc_cidr
}
output "nat_ip" {
        value = var.vpc_id == null ? (var.use-nat ? (length(aws_eip.nat)>0 ? aws_eip.nat.0.public_ip : "none") : (length(aws_vpc.project)>0 ? aws_vpc.project.0.cidr_block: "none")) : var.vpc_cidr
}
output route_tables {
	value= {
		private = [
			for table in aws_route_table.project:
			table.id
		]
		public = [
			for table in aws_route_table.projectp:
			table.id
		]
	}
}
