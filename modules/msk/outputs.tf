output "bootstrap_brokers_tls" {
  description = "TLS connection string for Kafka brokers."
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
  sensitive   = true
}

output "security_group_id" {
  description = "The ID of the MSK cluster's security group."
  value       = aws_security_group.msk_sg.id
}