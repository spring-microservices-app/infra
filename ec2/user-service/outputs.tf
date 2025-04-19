output "user_service_instance_id" {
  value = aws_instance.user_service.id
}

output "user_service_private_ip" {
  value = aws_instance.user_service.private_ip
}

output "user_service_elastic_ip" {
  value = aws_eip.user_eip.public_ip
}

output "user_service_ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.user_eip.public_ip}"
}
