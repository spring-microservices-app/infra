output "stock_service_instance_id" {
  value = aws_instance.stock_service.id
}

output "stock_service_private_ip" {
  value = aws_instance.stock_service.private_ip
}

output "stock_service_elastic_ip" {
  value = aws_eip.stock_eip.public_ip
}

output "stock_service_ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.stock_eip.public_ip}"
}
