output "flask_public_ip" {
  description = "Public IP of Flask Backend EC2"
  value       = aws_instance.flask_ec2.public_ip
}

output "express_public_ip" {
  description = "Public IP of Express Frontend EC2"
  value       = aws_instance.express_ec2.public_ip
}
