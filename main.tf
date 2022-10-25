resource "aws_vpc" "test-env" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "subnet-1" {
  # creates a subnet
  cidr_block        = cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.test-env.id
  availability_zone = "us-west-2a"
  depends_on        = [aws_internet_gateway.test-env-gw]
}

resource "aws_security_group" "ingress-ssh" {
  name   = "allow-ssh-sg"
  vpc_id = aws_vpc.test-env.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-https" {
  name   = "allow-https-sg"
  vpc_id = aws_vpc.test-env.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip-test-env" {
  instance = aws_spot_instance_request.test_worker.spot_instance_id
  vpc      = true
  depends_on = [aws_internet_gateway.test-env-gw,
  aws_spot_instance_request.test_worker]
}

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.test-env.id
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.test-env.id

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
  ami                  = "ami-830c94e3"
  instance_type        = "t2.micro"
  spot_price           = "0.014"
  spot_type            = "one-time"
  wait_for_fulfillment = "true"

  key_name             = "spot_key"
  security_groups = [
    aws_security_group.ingress-ssh.id,
    aws_security_group.ingress-https.id
  ]
  subnet_id = aws_subnet.subnet-1.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp2"
  }
}
