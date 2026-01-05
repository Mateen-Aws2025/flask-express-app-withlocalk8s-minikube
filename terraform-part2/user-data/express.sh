#!/bin/bash
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git

cd /home/ec2-user

# Clone repository
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git

cd flask-express-app-withlocalk8s-minikube/express-backend

# Export backend URL (Flask private IP)
export BACKEND_URL=http://${FLASK_PRIVATE_IP}:5000

# Install Node dependencies
npm install

# Start Express app
nohup node index.js > express.log 2>&1 &
