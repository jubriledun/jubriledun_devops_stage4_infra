output "server_ip" {
  value = aws_instance.stage4_inst.public_ip
}
