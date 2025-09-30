resource "aws_redshift_subnet_group" "main" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "redshift_sg" {
  name   = "${var.cluster_identifier}-sg"
  vpc_id = var.vpc_id
  # Ingress rule to allow access (e.g., from your IP or other resources) would be added here
}

resource "aws_redshift_cluster" "main" {
  cluster_identifier = var.cluster_identifier
  node_type          = "ra3.large"
  cluster_type       = "multi-node"
  number_of_nodes    = 2
  database_name      = "dev"
  master_username    = "awsuser"
  master_password    = var.master_password
  publicly_accessible = false
  skip_final_snapshot = true

  cluster_subnet_group_name = aws_redshift_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.redshift_sg.id]
}