variable "default_tags" {
        type = map(string)
}
variable "policies" {
        type = set(string)
	default = []
}
variable "named_policies" {
        type = map(string)
	default={}
}

variable "service" {
	description = "Service that should be able to use this role"
	default = null
}
variable "aws_principals" {
	default = []
	type = list(string)
}
variable "principal_json" {
	default = null
	type = string
}
variable "role_name" {
  description = "Name of the role"
	default = null
}
variable "role_arn" {
	description = "ARN of an existing role (to use the module with existing roles)"
        default = null
}
variable "fake_policies" {
        type = set(string)
	default=[]
}
variable "fake_named_policies" {
        type = map(string)
        default={}
}
variable "policy_arns" {
	type = set(string)
        default=[]
}
variable "fake_policy_arns" {
        type = set(string)
        default=[]
}

