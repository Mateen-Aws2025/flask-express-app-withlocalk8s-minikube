#!/bin/bash
set -e

yum update -y
yum install -y git python3 python3-pip

cd /home/ec2-user

# Clone repo
git clone https://github.com/Mateen-Aws2025/flask-express-app-withlocalk8s-minikube.git
chown -R ec2-user:ec2-user flask-express-app-withlocalk8s-minikube

# Flask app
cd flask-express-app-withlocalk8s-minikube/flask-frontend
pip3 install -r requirements.txt

nohup python3 app.py > flask.log 2>&1 &
