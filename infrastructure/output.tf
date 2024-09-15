output "instance_id" {
  description = "The ID of the web server instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "The public IP of the web server instance"
  value       = aws_instance.web.public_ip
}
