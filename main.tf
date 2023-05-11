# Declare the provider
provider "aws" {
  region = "us-east-2"
}

# Define the VPC
resource "aws_vpc" "fateh-poc-tf" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "poc-vpc"
  }
}

# Create the internet gateway
resource "aws_internet_gateway" "fateh-poc-tf" {
  vpc_id = aws_vpc.fateh-poc-tf.id

  tags = {
    Name = "poc-igw"
  }
}

# Define the subnet in the VPC - Subnet 1
resource "aws_subnet" "fateh-poc-tf1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.fateh-poc-tf.id
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "poc-subnet-1"
  }
}

# Define the subnet in the VPC - Subnet 2
resource "aws_subnet" "fateh-poc-tf2" {
  vpc_id = aws_vpc.fateh-poc-tf.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "poc-subnet-2"
  }
}

# Create an internet gateway attachment for the first subnet
resource "aws_route_table" "fateh-rt1" {
  vpc_id = aws_vpc.fateh-poc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fateh-poc-tf.id
  }

  tags = {
    Name = "poc-route-table1"
  }
}

resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.fateh-poc-tf1.id
  route_table_id = aws_route_table.fateh-rt1.id
}

# Create an internet gateway attachment for the second subnet
resource "aws_route_table" "fateh-rt2" {
  vpc_id = aws_vpc.fateh-poc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fateh-poc-tf.id
  }

  tags = {
    Name = "poc-route-table2"
  }
}

resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.fateh-poc-tf2.id
  route_table_id = aws_route_table.fateh-rt2.id
}

# Define the Security Group
resource "aws_security_group" "fateh-poc-tf" {
  name_prefix = "poc-sg-"
  vpc_id = aws_vpc.fateh-poc-tf.id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  # Open traffic for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Open traffic for HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_instance" "fateh-poc-tf" {
  count = 2

  ami = "ami-0a695f0d95cefc163"
  instance_type = "t3a.medium"
  key_name      = "terraform-key"
  subnet_id = count.index % 2 == 0 ? aws_subnet.fateh-poc-tf1.id : aws_subnet.fateh-poc-tf2.id
  vpc_security_group_ids = [aws_security_group.fateh-poc-tf.id]
  availability_zone = element(var.availability_zones, count.index)
  user_data = "sudo apt-get update && sudo apt-get install -y nginx docker.io docker-compose"
  tags = {
    Name = "fateh-poc-tf-instance-${count.index + 1}"
  }
}
