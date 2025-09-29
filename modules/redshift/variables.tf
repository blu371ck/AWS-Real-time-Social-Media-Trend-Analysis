variable "cluster_identifier" {
  type = string
}
variable "master_password" {
  type      = string
  sensitive = true
}
variable "vpc_id" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}