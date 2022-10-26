data "aws_ami" "my_ami" {
  owners = ["066673448157"]
  filter {
    name   = "name"
    # search for your AMI as you would in AWS console.
    values = ["*dsc102-dask-environment-public*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
}

data "aws_ec2_spot_price" "market" {
  instance_type     = "t2.xlarge"
  availability_zone = var.avail_zone

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}
