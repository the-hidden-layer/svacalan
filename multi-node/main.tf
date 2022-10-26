provider "aws" {
  region = var.region
}

locals {
  avail_zone = var.avail_zone
}

resource "aws_spot_instance_request" "node" {
  ami                         = data.aws_ami.my_ami.id
  spot_price                  = var.spot_price
  instance_type               = var.instance_type
  key_name                    = "spot-key"
  monitoring                  = true
  associate_public_ip_address = true
  wait_for_fulfillment        = true
  count                       = var.num_instances
  security_groups             = [aws_default_security_group.main_vpc_security_group.id]
  subnet_id                   = aws_subnet.main_vpc_subnet.id
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_volume_size
    volume_type = "gp2" # SSD
  }

  //user_data = count.index == 0 ? file("scheduler.sh") : file("worker.sh")
  user_data = file("${path.module}/worker.sh")

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=${count.index == 0 ? "Scheduler" : "Worker-${count.index}"} --region ${var.region}"
  }
}

