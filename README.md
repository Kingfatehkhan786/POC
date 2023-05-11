# 1.Create a Terraform module

Install Terraform on your local machine.
Create a directory for your Terraform project.
Inside the directory, create a file named main.tf with the following code:

'''provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "example" {
  name_prefix = "example-"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  count         = 2

  subnet_id = aws_subnet.example.id

  tags = {
    Name = "example-instance-${count.index + 1}"
  }
}

resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
}

output "instance_public_ips" {
  value = aws_instance.example.*.public_ip
}'''


Initialize your Terraform project by running the command terraform init
Plan and apply your Terraform project by running the command terraform plan and terraform apply

# 2.Set up a GitHub action to deploy the Terraform code
Create a new repository on GitHub.
Clone the repository to your local machine.
Inside the repository, create a directory named .github/workflows.
Inside the .github/workflows directory, create a file named terraform.yml with the following code:

name: Terraform Apply

on:
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Terraform Init
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 1.0.0
    - name: Terraform Apply
      uses: hashicorp/terraform-github-actions@master
      with:
        args: |
          -auto-approve

Commit and push the changes to the repository.
Go to the Actions tab in your GitHub repository and verify that the workflow has run successfully.

# 3.Verify the EC2 instances were created
Go to the EC2 Dashboard on AWS.
Verify that two instances have been created and are running.
Copy the public IP addresses of the instances.

# 4.Modify the Terraform code to apply a new security policy
Update the aws_security_group resource in your main.tf file to allow traffic for HTTP and HTTPS:

resource "aws_security_group" "example" {
  name_prefix = "example-"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

Plan and apply your Terraform project again by running the command `terraform plan and terraform apply.

# 5.Install Nginx, Docker, and Docker Compose on the EC2 instances

SSH into one of the EC2 instances using the command:
ssh -i /path/to/key.pem ec2-user@<public_ip>
Install Nginx, Docker, and Docker Compose on the EC2 instance by running the following commands:
sudo amazon-linux-extras install -y nginx1.12
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
Repeat the same steps for the other EC2 instance.

# 6.Create a Docker Compose file to install the Kafka cluster on one EC2 instance
SSH into the EC2 instance that will host the Kafka cluster.
Create a directory for your Kafka project and change into it:

mkdir kafka && cd kafka

# Create a file named docker-compose.yml with the following code:

'''version: '3.8'

services:
  zookeeper:
    image: wurstmeister/zookeeper
    container_name: zookeeper
    restart: always
    ports:
      - "2181:2181"

  kafka:
    image: wurstmeister/kafka
    container_name: kafka
    restart: always
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    depends_on:
      - zookeeper'''

Run the following command to start the Kafka cluster:
docker-compose up -d

Verify that the Kafka cluster is running by running the following command:
docker ps

You should see two containers named kafka and zookeeper.

# 7.Create a Lambda function to publish messages on the Kafka cluster
Go to the Lambda Dashboard on AWS.
Click on "Create function" and select "Author from scratch".
Enter a name for your Lambda function and select "Python 3.8" as the runtime.
In the "Function code" section, paste the following code:

'''import boto3
from kafka import KafkaProducer

def lambda_handler(event, context):
    producer = KafkaProducer(bootstrap_servers=['localhost:9092'])
    producer.send('my-topic', b'Hello, World!')
Scroll down to the "Environment variables" section and add a variable named KAFKA_BOOTSTRAP_SERVERS with a value of localhost:9092.
Scroll down to the "Permissions" section and create a new role with the following policy:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}'''

Click on "Create function".

# 8.Create a Lambda function to subscribe to messages from the Kafka cluster

Go to the Lambda Dashboard on AWS.
Click on "Create function" and select "Author from scratch".
Enter a name for your Lambda function and select "Python 3.8" as the runtime.
In the "Function code" section, paste the following code:

'''import boto3
from kafka import KafkaConsumer

def lambda_handler(event, context):
    consumer = KafkaConsumer(
        'my-topic',
        bootstrap_servers=['localhost:9092'],
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        group_id='my-group',
        value_deserializer=lambda x: x.decode('utf-8')
    )

    for message in consumer:
        print(message.value)'''

Scroll down to the "Environment variables" section and add a variable named KAFKA_BOOTSTRAP_SERVERS with a value of localhost:9092.
Scroll down to the "Permissions" section and create a new role with the following policy:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}

Click on "Create function".

Congratulations! You have completed all the steps for this problem. You have built a baseline AWS infrastructure using Terraform, created a Terraform module to create a VPC, security group, and 2 EC2 instances, set up a GitHub action to deploy the Terraform code, verified the EC2 instances were created, modified the Terraform code to apply a new security policy, opened traffic for HTTP and HTTPS, installed Nginx, Docker, and Docker Compose on the EC2 instances, created a Docker Compose file to install the Kafka cluster on one EC2 instance, and created two Lambda functions to publish and subscribe messages from the Kafka cluster.
