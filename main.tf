# Declare the provider
provider "aws" {
  region = var.aws_region
}

# Define the VPC
resource "aws_vpc" "poc-tf" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.vpc_name
  }
}

# Create the internet gateway
resource "aws_internet_gateway" "poc-tf" {
  vpc_id = aws_vpc.poc-tf.id

  tags = {
    Name = var.igw_name
  }
}

# Define the subnet in the VPC - Subnet 1
resource "aws_subnet" "poc-tf1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.poc-tf.id
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "poc-subnet-1"
  }
}

# Define the subnet in the VPC - Subnet 2
resource "aws_subnet" "poc-tf2" {
  vpc_id = aws_vpc.poc-tf.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "poc-subnet-2"
  }
}

# Create an internet gateway attachment for the first subnet
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.poc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc-tf.id
  }

  tags = {
    Name = "poc-route-table1"
  }
}

resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.poc-tf1.id
  route_table_id = aws_route_table.rt1.id
}

# Create an internet gateway attachment for the second subnet
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.poc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc-tf.id
  }

  tags = {
    Name = "poc-route-table2"
  }
}

resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.poc-tf2.id
  route_table_id = aws_route_table.rt2.id
}

# Define the Security Group
resource "aws_security_group" "poc-tf" {
  name_prefix = "poc-sg-"
  vpc_id = aws_vpc.poc-tf.id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  # Open traffic for HTTP
  ingress {
    from_port   = var.ingress_port_from_1
    to_port     = var.ingress_port_to_1
    protocol    = var.ingress_protocol_1
    cidr_blocks = [var.ingress_cidr1]
  }

# Open traffic for HTTPS
  ingress {
    from_port   = var.ingress_port_from_2
    to_port     = var.ingress_port_to_2
    protocol    = var.ingress_protocol_2
    cidr_blocks = [var.ingress_cidr2]
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the variable for availability zones
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]  
}

# Define the EC2 instances
resource "aws_instance" "poc-tf" {
  count = 2

  ami = var.ami_id
  instance_type = var.instance_type
  key_name      = var.instance_key
  subnet_id = count.index % 2 == 0 ? aws_subnet.poc-tf1.id : aws_subnet.poc-tf2.id
  vpc_security_group_ids = [aws_security_group.poc-tf.id]
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "poc-tf-instance-${count.index + 1}"
  }
}
