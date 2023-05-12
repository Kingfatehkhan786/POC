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
  count = length(var.az)
  cidr_block = var.sub1_cidr
  vpc_id = aws_vpc.poc-tf.id
  availability_zone = element(var.az, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = var.sub1_name
  }
}

# Define the subnet in the VPC - Subnet 2
resource "aws_subnet" "poc-tf2" {
  count = length(var.az)
  vpc_id = aws_vpc.poc-tf.id
  cidr_block = var.sub2_cidr
  availability_zone = element(var.az, count.index+1)
  map_public_ip_on_launch = true

  tags = {
    Name = var.sub2_name
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
  subnet_id      = aws_subnet.poc-tf1[count.index].id
  route_table_id = aws_route_table.rt1[count.index].id
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
  subnet_id      = aws_subnet.poc-tf2[count.index].id
  route_table_id = aws_route_table.rt2[count.index].id
}

# Define the Security Group
resource "aws_security_group" "poc-tf" {
  name_prefix = var.sg_name
  vpc_id = aws_vpc.poc-tf.id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ingress_port_from_1
    to_port     = var.ingress_port_to_1
    protocol    = var.ingress_protocol_1
    cidr_blocks = [var.ingress_cidr1]
  }


  ingress {
    from_port   = var.ingress_port_from_2
    to_port     = var.ingress_port_to_2
    protocol    = var.ingress_protocol_2
    cidr_blocks = [var.ingress_cidr2]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the variable for availability zones
#variable "availability_zones" {
 # type    = list(string)
  #default = var.az 
#}

# Define the EC2 instances
resource "aws_instance" "poc-tf" {
  count = 2
  ami = var.ami_id
  instance_type = var.instance_type
  key_name      = var.instance_key
  subnet_id = count.index % 2 == 0 ? aws_subnet.poc-tf1[count.index].id : aws_subnet.poc-tf2[count.index].id
  vpc_security_group_ids = [aws_security_group.poc-tf.id]
  availability_zone = element(var.az, count.index)
  tags = {
    Name = var.instance_name
  }
}
