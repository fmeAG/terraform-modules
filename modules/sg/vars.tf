variable "tags" {
        type = map(string)
}
variable "name" {
        description = "Name of the variable"
}
variable "vpc_id" {
        description = "ID of the VPC for SG"
}
variable "rules" {
        description = "Set of the security group rules to attach to the SG"
	type = set(string)
}
variable "description" {}

