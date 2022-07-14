resource "aws_instance" "vm" {
  ami           = var.ami
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.id 
  key_name = aws_key_pair.key_pair_1.key_name
  tags=merge(var.default_tags,
  {  
    Name = var.server_name
  }
  )
  root_block_device {
	  volume_type = "gp2"
	  volume_size = var.volume_size
	  encrypted = true
	  kms_key_id = var.kms_key_id == null ? aws_kms_key.key.0.arn : var.kms_key_id 
  }
  user_data_base64  = data.template_cloudinit_config.config.rendered
  vpc_security_group_ids = var.security_groups
  subnet_id = var.subnet.id
  associate_public_ip_address = var.make_public
  lifecycle {
    ignore_changes= [associate_public_ip_address]
  }

}
resource "aws_key_pair" "key_pair_1" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_keys.0
}
