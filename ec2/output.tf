output "public-ip" {
  value = aws_instance.my-instance[*].public_ip

}