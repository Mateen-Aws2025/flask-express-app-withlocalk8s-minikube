##############################
# PROVIDER
##############################
provider "aws" {
  region = var.aws_region
}

##############################
# VPC
##############################
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "Part2-VPC" }
}

##############################
# Public Subnet
##############################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # adjust for your region
  tags = { Name = "Part2-Public-Subnet" }
}

##############################
# Internet Gateway
##############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "Part2-IGW" }
}

##############################
# Route Table
##############################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Part2-Public-RT" }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

##############################
# SECURITY GROUPS (No cycles)
##############################

# Express SG
resource "aws_security_group" "express_sg" {
  name        = "express-sg"
  description = "Express frontend SG"
  vpc_id      = aws_vpc.main_vpc.id

  # Public access
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Inter-EC2 communication (Flask can reach Express)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Flask SG
resource "aws_security_group" "flask_sg" {
  name        = "flask-sg"
  description = "Flask backend SG"
  vpc_id      = aws_vpc.main_vpc.id

  # Public access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Inter-EC2 communication (Flask can talk to Express if needed)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################
# EXPRESS EC2
##############################
resource "aws_instance" "express_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.express_sg.id]
  key_name               = var.key_name

  user_data = file("${path.module}/user-data/express.sh")

  tags = {
    Name = "Express-Frontend-Part2"
  }
}

##############################
# FLASK EC2 (Depends on Express)
##############################
resource "aws_instance" "flask_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  key_name               = var.key_name

  depends_on = [aws_instance.express_ec2]
   connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/ec2-user/terraform-runner-ec2.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3 git",
      "cd /home/ec2-user",
      "git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git || true",
      "cd flask-express-app-withlocalk8s-minikube/flask-frontend",
      "export BACKEND_URL=http://${aws_instance.express_ec2.private_ip}:3000",
      "pip3 install -r requirements.txt",
      "nohup python3 app.py --host=0.0.0.0 --port=5000 > flask.log 2>&1 &"
    ]
  }

  tags = {
    Name = "Flask-Backend-Part2"
  }
}

##############################
# OUTPUTS
##############################
output "express_public_ip" {
  description = "Public IP of Express frontend"
  value       = aws_instance.express_ec2.public_ip
}

output "flask_public_ip" {
  description = "Public IP of Flask backend"
  value       = aws_instance.flask_ec2.public_ip
}
