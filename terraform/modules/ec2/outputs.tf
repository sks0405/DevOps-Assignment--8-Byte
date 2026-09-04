output "instance_id" {
  description = "Application EC2 instance ID"
  value       = aws_instance.app.id
}

output "private_ip" {
  description = "Application EC2 private IP"
  value       = aws_instance.app.private_ip
}
