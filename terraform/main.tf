resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

user_data = <<-EOF
#!/bin/bash
set -e

yum update -y
yum install -y git python3 python3-pip

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

cd /home/ec2-user

# Clone repo
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git
chown -R ec2-user:ec2-user flask-express-app-withlocalk8s-minikube

####################
# FLASK APP
####################
cd flask-express-app-withlocalk8s-minikube/flask-frontend
pip3 install -r requirements.txt
nohup python3 app.py > flask.log 2>&1 &

####################
# EXPRESS APP
####################
cd ../express-backend
npm install
nohup npm start > express.log 2>&1 &
EOF

  tags = {
    Name = "flask-express-app"
  }
}

