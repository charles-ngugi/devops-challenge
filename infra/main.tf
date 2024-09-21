# Cloud Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC
resource "aws_vpc" "birdapi" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "birdapi VPC"
  }
}

# IGW
resource "aws_internet_gateway" "birdapi_igw" {
  vpc_id = aws_vpc.birdapi.id
  tags = {
    Name = "birdapi Internet Gateway"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.birdapi.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "af-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.birdapi.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "af-south-1a"
  tags = {
    Name = "Private Subnet"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.birdapi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.birdapi_igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "birdapi_sg" {
  vpc_id = aws_vpc.birdapi.id
  name   = "instance_security_group"

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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Instance Security Group"
  }
}

# EC2 Instance
resource "aws_instance" "birdapi_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.birdapi_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp2"
    encrypted   = true
  }

  # Install required dependencies
  user_data = <<-EOF
    #!/bin/bash

    # Update the system and install required packages
    echo "Updating system..." 
    sudo apt-get update -y 
    sudo apt-get dist-upgrade -y 

    # Install Docker and MicroK8s
    echo "Installing Docker..." 
    sudo apt-get install -y docker.io
    sudo usermod -aG docker ubuntu

    # Install MicroK8s
    sudo snap install microk8s --classic
    sudo usermod -aG microk8s ubuntu
    sudo mkdir -p /home/ubuntu/.kube
    sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
    microk8s status --wait-ready 
    microk8s enable dns ingress storage 

    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 

    microk8s kubectl create namespace monitoring

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update


    helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true --namespace ingress-nginx
    helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
    helm install grafana grafana/grafana --namespace monitoring

  EOF


  disable_api_termination = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.instance_name
  }

  key_name = var.key_name
}
