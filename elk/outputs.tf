output "elk_instance_public_ip" {
  value = aws_instance.elk.public_ip
}

output "elk_dashboard_url" {
  value = "http://${aws_instance.elk.public_ip}:5601"
}
output "elk_elasticsearch_url" {
  value = "http://${aws_instance.elk.public_ip}:9200"
}

output "elk_service_ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip_association.elk_eip.public_ip}"
}
