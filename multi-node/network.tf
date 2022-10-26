resource "aws_vpc" "main_vpc" {
  cidr_block           = var.my_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_vpc_igw"
  }
}

resource "aws_default_route_table" "main_vpc_default_route_table" {
  default_route_table_id = aws_vpc.main_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }

  tags = {
    Name = "main_vpc_default_route_table"
  }
}

resource "aws_subnet" "main_vpc_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.my_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = local.avail_zone

  tags = {
    Name = "main_vpc_subnet"
  }
}

resource "aws_default_network_acl" "main_vpc_nacl" {
  default_network_acl_id = aws_vpc.main_vpc.default_network_acl_id
  subnet_ids             = [aws_subnet.main_vpc_subnet.id]

  ingress {
    protocol = -1
    rule_no  = 1
    action   = "allow"
    #cidr_block = "${var.my_ip}"
    cidr_block = "0.0.0.0/0" # allow any IP
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 2
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "main_vpc_nacl"
  }
}

resource "aws_default_security_group" "main_vpc_security_group" {
  vpc_id = aws_vpc.main_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jupyter notebook
  ingress {
    from_port   = 8000
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # dask dashboard
  ingress {
    from_port   = 8001
    to_port     = 8787
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for git clone
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main_vpc_security_group"
  }
}

