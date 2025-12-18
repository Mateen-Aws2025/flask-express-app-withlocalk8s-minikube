resource "aws_instance" "flask_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  user_data              = file("user-data/flask.sh")

  tags = {
    Name = "Flask-Frontend-EC2"
  }
}

resource "aws_instance" "express_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.express_sg.id]
  user_data              = file("user-data/express.sh")

  tags = {
    Name = "Express-Backend-EC2"
  }
}
