data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true
  dynamic "part" {
    for_each = local.user_data_parts
    content {
      filename      = part.value.filename
      content_type  = part.value.content_type
      content       = part.value.content
    }
  }
}

locals {
user_data_parts = concat([{
      filename     = "1-default.sh"
      content_type = "text/x-shellscript"
      content      = data.template_file.default_script.rendered
    }], var.additional_user_data
  )
}

data "template_file" "default_script" {
  template  = file("${path.module}/user_data.sh")
  vars      = {
    PUBLIC_KEYS             = jsonencode(var.ssh_public_keys)
    USER_NAME               = var.user_name
    INSTALLER               = var.installer
    PERSISTENT_STORAGE      = var.persistent_volume_size
    PERSISTENT_VOLUME_MOUNT = var.persistent_volume_mount
    REGION                  = data.aws_region.current.name
    ADDITIONAL_TOOLS        = jsonencode(var.additional_tools)
  }
}

