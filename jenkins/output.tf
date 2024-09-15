output "jenkins_instance_id" {
  description = "The ID of the Jenkins server instance"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "The public IP of the Jenkins server instance"
  value       = aws_instance.jenkins.public_ip
}
