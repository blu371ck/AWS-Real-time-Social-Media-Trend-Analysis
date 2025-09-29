output "s3_bucket_name" {
  description = "The name of the S3 data lake bucket."
  value       = module.s3_data_lake.bucket_name
}

output "msk_bootstrap_brokers" {
  description = "The connection string for the MSK Kafka cluster."
  value       = module.msk_cluster.bootstrap_brokers_tls
  sensitive   = true
}

output "redshift_endpoint" {
  description = "The endpoint for the Redshift cluster."
  value       = module.redshift_cluster.endpoint
  sensitive   = true
}