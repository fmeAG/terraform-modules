output "public_ip"{
  description = "IP address of the vm"
  value = aws_instance.vm.public_ip
}
output "key_pair_name" {
  description = "Name of the key pair created"
  value = aws_key_pair.key_pair_1.key_name
}
output "instance_id"{
  description = "ID of the vm"
  value = aws_instance.vm.id
}
output "kms_key_id"{
  value = length(aws_kms_key.key)>0 ? aws_kms_key.key.0.arn : ( var.kms_key_id == null ? "none" : var.kms_key_id )
}
output "instance_arn"{
  description = "ARN of the vm"
  value = aws_instance.vm.arn
}
