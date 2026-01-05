################################
# VPC & Networking
################################

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "part2-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "part2-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "part2-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "part2-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

################################
# Security Groups
################################

# Flask Backend Security Group
resource "aws_security_group" "flask_sg" {
  name   = "flask-sg-part2"
  vpc_id = aws_vpc.app_vpc.id

  # Public access to Flask
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from Express EC2
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.express_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-sg-part2"
  }
}

# Express Frontend Security Group
resource "aws_security_group" "express_sg" {
  name   = "express-sg-part2"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    Name = "express-sg-part2"
  }
}

################################
# EC2 Instances
################################

# Flask Backend EC2
resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  key_name               = var.key_name

  user_data = templatefile("user-data/flask.sh", {
  FLASK_PRIVATE_IP = aws_instance.express_ec2.private_ip
})


  tags = {
    Name = "Flask-Backend-Part2"
  }
}

# Express Frontend EC2
resource "aws_instance" "express_ec2" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.express_sg.id]
  key_name               = var.key_name

  user_data = templatefile("user-data/express.sh", {
    FLASK_PRIVATE_IP = aws_instance.flask_ec2.private_ip
  })

  tags = {
    Name = "Express-Frontend-Part2"
  }
}
