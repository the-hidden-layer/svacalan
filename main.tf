data "aws_ami" "dask_env" {
  owners = ["066673448157"]
  filter {
    name   = "name"
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
  availability_zone = "us-west-2a"

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}

resource "aws_vpc" "mainvpc" {
  # virtual private cloud
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_default_security_group" "default" {
  # default security rules
  vpc_id = aws_vpc.mainvpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

resource "aws_subnet" "subnet-1" {
  # creates a subnet
  cidr_block        = cidrsubnet(aws_vpc.mainvpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.mainvpc.id
  availability_zone = "us-west-2a"
  depends_on        = [aws_internet_gateway.test-env-gw]
}

resource "aws_eip" "ip-scheduler" {
  # assoc instance with an AWS Elastic IP
  instance = aws_spot_instance_request.scheduler.spot_instance_id
  vpc      = true
  depends_on = [aws_internet_gateway.test-env-gw,
  aws_spot_instance_request.scheduler]
}

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.mainvpc.id
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table-test-env.id
}

resource "aws_key_pair" "spot_key" {
  key_name   = "spot_key"
  public_key = file("/Users/astrlux/Downloads/public_key.pem")
}

resource "aws_spot_instance_request" "scheduler" {
  ami           = data.aws_ami.dask_env.id
  instance_type = "t2.xlarge"

  # attach 100GB EBS volume to instance
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
    volume_type = "gp2" # flash SSD
  }

  # commands to run inside worker instance
  user_data = file("scheduler.sh")

  # set maximum price $0.05 above current market offer.
  spot_price           = data.aws_ec2_spot_price.market.spot_price + 0.05
  spot_type            = "one-time"
  wait_for_fulfillment = "true"

  # security policy
  key_name        = "spot_key"
  security_groups = [aws_default_security_group.default.id]
  subnet_id       = aws_subnet.subnet-1.id

  tags = {
    Name = "Scheduler"
  }
}

resource "aws_spot_instance_request" "worker" {
  count         = 4
  ami           = data.aws_ami.dask_env.id
  instance_type = "t2.xlarge"

  # attach 100GB EBS volume to instance
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
    volume_type = "gp2" # flash SSD
  }

  # commands to run inside worker instance
  user_data = file("worker.sh")

  # set maximum price $0.05 above current market offer.
  spot_price           = data.aws_ec2_spot_price.market.spot_price + 0.05
  spot_type            = "one-time"
  wait_for_fulfillment = "true"

  # security policy
  key_name = "spot_key"

  tags = {
    Name = "Worker-${count.index}"
  }
}
