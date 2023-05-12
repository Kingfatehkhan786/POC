# variables.tf

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  default     = "poc-vpc"
}

variable "igw_name" {
  type        = string
  default     = "poc-igw"
}

variable "sub1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
}

variable "az" {
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "sub1_name" {
  type        = string
  default     = "poc-subnet-1"
}

variable "sub2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
}


variable "sub2_name" {
  type        = string
  default     = "poc-subnet-2"
}

variable "sg_name" {
  type        = string
  default     = "poc-sg"
}

variable "ingress_protocol_1" {
  type        = string
  default     = "tcp"
}

variable "ingress_port_from_1" {
  type        = string
  default     = "80"
}

variable "ingress_port_to_1" {
  type        = string
  default     = "80"
}

variable "ingress_cidr1" {
  type        = string
  default     = "0.0.0.0/0"
}

variable "ingress_protocol_2" {
  type        = string
  default     = "tcp"
}

variable "ingress_port_from_2" {
  type        = string
  default     = "443"
}

variable "ingress_port_to_2" {
  type        = string
  default     = "443"
}

variable "ingress_cidr2" {
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3a.medium"
}

variable "instance_key" {
  description = "The EC2 instance type"
  type        = string
  default     = "terraform.ppk"
}

variable "ami_id" {
  type        = string
  default     = "ami-0a695f0d95cefc163"
}

variable "instance_name" {
  description = "The ID of the VPC subnet where the EC2 instance will be launched"
  type        = string
  default     = "poc-tf-instance-"
}

