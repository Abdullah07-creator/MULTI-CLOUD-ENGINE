# 1. Fetch latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. AWS Virtual Private Cloud (VPC)
resource "aws_vpc" "primary" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "multi-cloud-aws-vpc"
    Environment = "production"
  }
}

# 3. Public Subnet
resource "aws_subnet" "primary_public" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "multi-cloud-aws-subnet"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "primary_igw" {
  vpc_id = aws_vpc.primary.id

  tags = {
    Name = "multi-cloud-aws-igw"
  }
}

# 5. Route Table & Association
resource "aws_route_table" "primary_public_rt" {
  vpc_id = aws_vpc.primary.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name = "multi-cloud-aws-rt"
  }
}

resource "aws_route_table_association" "primary_public_assoc" {
  subnet_id      = aws_subnet.primary_public.id
  route_table_id = aws_route_table.primary_public_rt.id
}

# 6. Security Group (HTTP Port 5000 & 80 Inbound)
resource "aws_security_group" "primary_sg" {
  name        = "multi-cloud-aws-sg"
  description = "Allow inbound HTTP traffic for microservice"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description = "Flask App Port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Standard Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "multi-cloud-aws-sg"
  }
}

# 7. EC2 Instance Host
resource "aws_instance" "primary_app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.primary_public.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]

  # User Data Script creating app code, building image, and running container
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              mkdir -p /app
              cat << 'APP' > /app/requirements.txt
              flask==3.0.3
              gunicorn==22.0.0
              APP

              cat << 'APP' > /app/app.py
              import os
              from flask import Flask, jsonify

              app = Flask(__name__)

              @app.route('/')
              def home():
                  return jsonify({
                      "status": "online",
                      "service": "multi-cloud-engine-api",
                      "provider": "AWS Primary Cloud",
                      "region": "${var.aws_region}",
                      "message": "Hello from Multi-Cloud Deployment Engine on AWS!"
                  })

              @app.route('/health')
              def health():
                  return jsonify({"status": "healthy"}), 200

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              APP

              cat << 'APP' > /app/Dockerfile
              FROM python:3.11-slim
              WORKDIR /app
              COPY requirements.txt .
              RUN pip install --no-cache-dir -r requirements.txt
              COPY app.py .
              EXPOSE 5000
              CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
              APP

              cd /app
              docker build -t aws-app:v1 .
              docker run -d -p 5000:5000 --restart always --name aws-microservice aws-app:v1
              EOF

  tags = {
    Name = "multi-cloud-aws-primary-server"
  }
}

# 8. Output Public IP Endpoint
output "aws_primary_public_ip" {
  value       = aws_instance.primary_app.public_ip
  description = "Public IP of Primary AWS Compute Instance"
}
