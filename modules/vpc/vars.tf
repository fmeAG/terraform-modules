variable "cidr_range" {
	description = "The CIDR range to use for the VPC"
	default     = "10.30.0.0/16"
}
variable "private_subnet_cidrs" {
	description = "The CIDR ranges for the private subnets"
	type=map(string)
	default={}
}
variable "public_subnet_cidrs" {
        description = "The CIDR ranges for the public subnets"
        type=map(string)
        default={}
}
variable "nat-subnet" {
  description = "The index of the subnet to deploy the NAT gateway in"
  default     = "0"
}
variable "use-nat"{
	type = bool
	default = true
}
variable "default_tags" {
	type = map(string)
}
variable "private_subnet_tags" {
  type = map(string)
  default = {}
}
variable "public_subnet_tags" {
  type = map(string)
  default = {}
}

variable "vpc_id" {
	description = "If present, the module will fake the creation of a VPC with outputs and do nothing"
	default = null
}
variable "vpc_cidr" {
        description = "If present, the module will fake the creation of a VPC with outputs and do nothing"
	default = null
}
variable "private_subnet_ids" {
	default = null
	type = map(string)
}
variable "public_subnet_ids" {
        default = null
        type = map(string)
}
variable private2public {
	default = false
	type = bool
	description = "This will make private subnets public by attaching them to the IGW, which is less secure but allows to save costs associated with NAT Gateways or instances"
}
variable custom_public_routes {
  type = set(string)
  default = []
}
variable custom_private_routes {
  type = set(string)
  default = []
}
variable secondary_cidrs {
  type = set(string)
  default = []
}
