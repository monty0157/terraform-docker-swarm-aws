data "template_file" "init_worker" {
  count    = var.workers
  template = file("${path.module}/init_worker.py")

  vars = {
    s3_bucket      = aws_s3_bucket.terraform.bucket
    instance_index = count.index
    swapsize       = var.swap_size
    vpc_name       = local.dns_name
  }
}

data "template_cloudinit_config" "workers" {
  count         = var.workers
  gzip          = "true"
  base64_encode = "true"

  part {
    content = file("${path.module}/common.cloud-config")
  }

  part {
    filename     = "extra.cloud-config"
    content      = var.cloud_config_extra
    content_type = "text/cloud-config"
  }

  part {
    filename     = "init_worker.py"
    content      = data.template_file.init_worker[count.index].rendered
    content_type = "text/x-shellscript"
  }

  part {
    filename     = "extra.sh"
    content      = var.cloud_config_extra_script
    content_type = "text/x-shellscript"
  }
}

resource "aws_instance" "workers" {
  depends_on = [
    aws_s3_bucket.terraform,
    aws_instance.managers,
  ]

  count         = var.workers
  ami           = data.aws_ami.base_ami.id
  instance_type = var.instance_type_node
  subnet_id     = aws_subnet.workers[(count.index + var.managers) % length(data.aws_availability_zones.azs.*.names)].id
  private_ip = cidrhost(
    aws_subnet.workers[count.index % length(data.aws_availability_zones.azs.*.names)].cidr_block,
    10 + count.index,
  )

  vpc_security_group_ids = local.security_group_ids

  iam_instance_profile = aws_iam_instance_profile.ec2.name
  user_data_base64     = data.template_cloudinit_config.workers[count.index].rendered
  key_name             = var.key_name

  tags = {
    Name = "${var.name} worker ${count.index}"
  }

  root_block_device {
    volume_size = var.volume_size
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data_base64,
    ]
  }

  credit_specification {
    cpu_credits = "standard"
  }
}

