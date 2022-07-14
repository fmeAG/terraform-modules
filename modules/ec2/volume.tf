resource "aws_ebs_volume" "persistent" {
  count = var.persistent_volume_size == 0 ? 0 : 1
  availability_zone = var.subnet.availability_zone
  size              = var.persistent_volume_size
  snapshot_id	= var.persistent_volume_snapshot
  encrypted = true
  type = "gp2"
  kms_key_id = var.kms_key_id == null ? aws_kms_key.key.0.arn : var.kms_key_id
}
resource "aws_volume_attachment" "ebs_att" {
  count = var.persistent_volume_size == 0 ? 0 : 1
  device_name = var.persistent_volume_mount
  volume_id   = aws_ebs_volume.persistent.0.id
  instance_id = aws_instance.vm.id
}
