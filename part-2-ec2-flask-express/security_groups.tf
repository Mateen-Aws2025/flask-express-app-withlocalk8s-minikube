# ------------------------
# Flask Security Group
# ------------------------
resource "aws_security_group" "flask_sg" {
  name        = "flask-sg"
  description = "Allow Flask traffic"
  vpc_id      = data.aws_vpc.default.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------
# Express Security Group
# ------------------------
resource "aws_security_group" "express_sg" {
  name        = "express-sg"
  description = "Allow Express traffic"
  vpc_id      = data.aws_vpc.default.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------
# Inter-EC2 Communication
# ------------------------
resource "aws_security_group_rule" "flask_to_express" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id         = aws_security_group.express_sg.id
  source_security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "express_to_flask" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id         = aws_security_group.flask_sg.id
  source_security_group_id = aws_security_group.express_sg.id
}

