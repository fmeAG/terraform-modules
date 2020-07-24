variable "default_tags" {
  type = map(string)
}
variable "name" {
  description = "Name of the LB"
}
variable "internal" {
  description = "Whether the LB should be internal"
	type = bool
}
variable "subnets" {
	description = "IDs of the subnets for the LB"
  type = list(string)
}
variable "vpc_id" {
  description = "IDs of VPC"
}
variable cross_zone_lb {
	description = "Whether to activate cross-zone load balancing"
	type = bool
	default = false
}
variable forward_listeners{
	description = "Listener and TG configurations in form of JSON"
	type = map(string)
	default={}
}
variable dns {
	type = map(string)
	default = {}
}
