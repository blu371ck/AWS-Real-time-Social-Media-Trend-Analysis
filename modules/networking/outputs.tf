output "endpoint" {
  description = "Redshift cluster endpoint (host:port)."
  value       = aws_redshift_cluster.main.endpoint
  sensitive   = true
}
output "database_name" {
  description = "Redshift database name."
  value       = aws_redshift_cluster.main.database_name
}