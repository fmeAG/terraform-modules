variable ssh_public_keys {
  description = "SSH key to access the EC2 instances"
	type = list(string)
}
variable ssh_key_name {
  description = "Name of the SSH key to access the EC2 instances"
}

variable vpc_id { 
	description = "ID of the VPC to deploy the VM in"
}

variable subnet {
  description = "The subnet to deploy the VM in"
}

variable instance_type {
  description = "Instance type of the VM"
}

variable volume_size {
        description = "Size of the volume for the VM"
}

variable security_groups {
  type = list(string)
}

variable user_name {
  description = "User name in the AMI"
	default="autodetect"
}
variable installer {
  description = "Installer used in the AMI"
	default="autodetect"
}
variable ami {
  description = "ID of the ami to use for the VM"
}
variable "default_tags" {
  type = map(string)
}
variable role {
  description = "IAM role for the instance profile"
}

variable kms_key_id {
	default = null
}
variable instance_profile_name {
	default = null
}
variable server_name {
	default = "Jumphost"
}
variable ssh_key_path_ssm {
	default=""
}
variable ssh_cidr_blocks {
	type=list(string)
	default = []
}
variable persistent_volume_size {
	default = 0
}
variable persistent_volume_mount {
	default = "sdf"
}
variable persistent_volume_snapshot {
        default = null
}
variable make_public {
	type = bool
	default = true
}
variable no_kms {
  type = bool
  default = false
}
variable additional_user_data {
  description = "Additional user_data for the nodes"
  type = list(map(string))
  default = []
}
variable additional_tools {
  type=list(string)
  default = []
}

