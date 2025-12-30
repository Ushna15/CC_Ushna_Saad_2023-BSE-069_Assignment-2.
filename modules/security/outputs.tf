output "nginx_sg_id" {
  value = aws_security_group.nginx-sg.id
}

output "backend_sg_id" {
  value = aws_security_group.backend-sg.id
}