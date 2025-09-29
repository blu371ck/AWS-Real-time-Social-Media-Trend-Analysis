variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" { # Renamed to plural
  type = list(string)
}

variable "producer_security_group_id" {
  description = "The security group ID of the EC2 producer instance."
  type        = string
}