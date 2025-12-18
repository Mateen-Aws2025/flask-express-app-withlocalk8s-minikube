#!/bin/bash
set -e

yum update -y
yum install -y git

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

cd /home/ec2-user

# Clone repo
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git
chown -R ec2-user:ec2-user flask-express-app-withlocalk8s-minikube

# Express app
cd flask-express-app-withlocalk8s-minikube/express-backend
npm install

nohup npm start > express.log 2>&1 &
