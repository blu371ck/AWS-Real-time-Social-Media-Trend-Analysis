resource "aws_security_group" "msk_sg" {
  name   = "${var.cluster_name}-msk-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port         = 9094
    to_port           = 9094
    protocol          = "tcp"
    security_groups  = [var.producer_security_group_id] 
  }

  ingress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-msk-sg"
  }
}

resource "aws_msk_cluster" "main" {
  cluster_name           = var.cluster_name
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type  = "kafka.t3.small"
    client_subnets = var.private_subnet_ids
    security_groups = [aws_security_group.msk_sg.id]
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
  }
}