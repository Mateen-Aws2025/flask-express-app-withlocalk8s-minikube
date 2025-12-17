resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
#!/bin/bash
set -e

# Update system and install dependencies
yum update -y
yum install -y git python3 python3-pip

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Go to ec2-user home
cd /home/ec2-user
# Remove folder if it exists, then clone
rm -rf flask-express-app-withlocalk8s-minik8s
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git
chown -R ec2-user:ec2-user flask-express-app-withlocalk8s-minikube

# Backend
cd flask-express-app-withlocalk8s-minikube/express-backend
pip3 install -r requirements.txt
nohup python3 app.py > flask.log 2>&1 &
# Start Express frontend on port 3000
cd ../flask-frontend
npm install -y
nohup npm start > /home/ec2-user/express.log 2>&1 &
EOF

  tags = {
    Name = "flask-express-app"
  }
}

