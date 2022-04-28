output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "node_public_ips" {
  value = aws_instance.node[*].public_ip
}
