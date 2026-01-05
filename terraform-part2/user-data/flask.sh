#!/bin/bash
yum update -y
yum install -y python3 git

cd /home/ec2-user
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git
cd flask-express-app-withlocalk8s-minikube/flask-frontend

# Set Express backend private IP
export BACKEND_URL=http://${EXPRESS_PRIVATE_IP}:3000

pip3 install -r requirements.txt

nohup python3 app.py --host=0.0.0.0 --port=5000 > flask.log 2>&1 &
