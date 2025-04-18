output "stock_service_instance_id" {
  description = "ID of the stock-service EC2 instance"
  value       = aws_instance.stock_service.id
}

output "stock_service_public_ip" {
  description = "Public IP of the stock-service EC2 instance"
  value       = aws_instance.stock_service.public_ip
}

output "stock_service_private_ip" {
  description = "Private IP of the stock-service EC2 instance"
  value       = aws_instance.stock_service.private_ip
}

output "stock_service_ssh_command" {
  description = "SSH command to connect to the stock-service EC2 instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.stock_service.public_ip}"
}
