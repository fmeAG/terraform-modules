data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true
  dynamic "part" {
  for_each = local.user_data_parts
  content {
    filename = part.value.filename
    content_type = part.value.content_type
    content = part.value.content
  }
  }
}

data "template_file" "default_script" {
        template = file("${path.module}/default.sh")
        vars = {
                INSPECTOR = var.use_inspector ? 1 : 0
        }
}
locals {
user_data_parts = concat([{
      filename     = "1-default.sh"
      content_type = "text/x-shellscript"
      content      = "${data.template_file.default_script.rendered}"
    }], var.additional_user_data
  )
}

