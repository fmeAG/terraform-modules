variable cluster_name {
        description = "Name of the cluster"
}
variable ssh_key_name {
        description = "Name of the SSH key to access the EC2 instances"
}
variable "default_tags" {
        type = map(string)
}
variable "additional_tags_ec2" {
  type = map(string)
  default = {}
}

variable vpc_id { 
	description = "ID of the VPC to deploy the VM in"
}
variable subnet_ids {
        description = "ID of the subnets for the ASG"
}
variable node_type {
        description = "Instance type of the VMs"
}
variable node_volume_size {
        description = "Size of the volume for the VMs"
}
variable instance_profile_name {
  default = "ASG"
}
variable use_inspector {
  description = "Whether AWS inspector should be active on the instances"
}
variable desired_capacity {
	description = "Desired capacity of the ASG"
}
variable max_size {
        description = "Max size of the ASG"
}
variable min_size {
        description = "Min size of the ASG"
}

variable ami {
        description = "ID of the ami to use for the VM"
}
variable sg_ids {
	description = "ID of the security group to attach to the nodes"
	type = list(string)
}
variable iam_role {
  default = null
  description = "An existing IAM role to use with the instance profile for the nodes. This role could be created with the iam_roles module"
}
variable additional_user_data {
  description = "Additional user_data for the nodes"
	type = list(map(string))
}
variable make_public {
	description = "If true, the cluster nodes will get public IP addresses"
	type = bool
	default = false
}
variable spot_price {
  default = null
}
