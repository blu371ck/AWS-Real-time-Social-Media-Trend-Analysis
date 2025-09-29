variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
  default     = "reddit-pipeline"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "redshift_master_password" {
  description = "The master password for the Redshift cluster."
  type        = string
  sensitive   = true
}

variable "reddit_client_id" {
  description = "The Client ID for the Reddit API."
  type        = string
  sensitive   = true
}

variable "reddit_client_secret" {
  description = "The Client Secret for the Reddit API."
  type        = string
  sensitive   = true
}

variable "reddit_username" {
  description = "The username for the Reddit account."
  type        = string
  sensitive   = true
}

variable "reddit_password" {
  description = "The password for the Reddit account."
  type        = string
  sensitive   = true
}

variable "reddit_user_agent" {
  description = "The user agent string for the Reddit API."
  type        = string
}