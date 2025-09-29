output "bootstrap_brokers_tls" {
  description = "TLS connection string for Kafka brokers."
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
  sensitive   = true
}