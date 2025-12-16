resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y git python3

    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs

    cd /home/terraform-user
    git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git

    cd flask-express-app-withlocalk8s-minikube/backend
    pip3 install -r requirements.txt
    nohup python3 app.py &

    cd ../frontend
    npm install
    nohup npm start &
  EOF

  tags = {
    Name = "flask-express-app"
  }
}
