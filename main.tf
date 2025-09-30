module "networking" {
  source = "./modules/networking"
}

module "s3_data_lake" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-data-lake-${random_string.bucket_suffix.id}"
}

module "iam_roles" {
  source = "./modules/iam"
}

module "msk_cluster" {
  source = "./modules/msk"

  cluster_name               = var.project_name
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  producer_security_group_id = aws_security_group.producer_sg.id

}

module "redshift_cluster" {
  source = "./modules/redshift"

  cluster_identifier = var.project_name
  master_password    = var.redshift_master_password
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
}

# --- Define Application Layer Resources ---

# This resource is needed to generate a unique suffix for the S3 bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_security_group" "producer_sg" {
  name   = "${var.project_name}-producer-sg"
  vpc_id = module.networking.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.8.20250915.0-kernel-6.12-x86_64"]
  }
}

resource "aws_iam_instance_profile" "producer_profile" {
  name = "${var.project_name}-producer-profile"
  role = module.iam_roles.ec2_ssm_role_name
}

resource "aws_instance" "producer_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = module.networking.private_subnet_ids[0] # Place in a private subnet
  vpc_security_group_ids = [module.networking.default_security_group_id, aws_security_group.producer_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.producer_profile.name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/init.sh.tpl", {
    reddit_client_id      = var.reddit_client_id
    reddit_client_secret  = var.reddit_client_secret
    reddit_username       = var.reddit_username
    reddit_password       = var.reddit_password
    reddit_user_agent     = var.reddit_user_agent
    msk_bootstrap_brokers = module.msk_cluster.bootstrap_brokers_tls
  })

  tags = {
    Name = "${var.project_name}-producer"
  }
}

resource "aws_s3_object" "flink_jar" {
  bucket = module.s3_data_lake.bucket_name
  key    = "flink-app/flink-stream-processor-1.0.jar"
  source = "../flink-stream-processor/target/flink-stream-processor-1.0.jar"
  etag   = filemd5("../flink-stream-processor/target/flink-stream-processor-1.0.jar")
}

resource "aws_kinesisanalyticsv2_application" "flink_app" {
  name                   = "${var.project_name}-flink-app"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = module.iam_roles.flink_role_arn

  application_configuration {
    application_code_configuration {
      code_content_type = "ZIPFILE"
      code_content {
        s3_content_location {
          bucket_arn = module.s3_data_lake.bucket_arn
          file_key   = "flink-app/flink-stream-porcessor-1.0.jar" # Placeholder path
        }
      }
    }
    flink_application_configuration {
      parallelism_configuration {
        configuration_type = "DEFAULT"
      }
    }
    application_snapshot_configuration {
      snapshots_enabled = false
    }
    environment_properties {
      property_group {
        property_group_id = "ProducerConfigProperties"
        property_map = {
          "bootstrap.servers" = module.msk_cluster.bootstrap_brokers_tls
          "s3.sink.path"      = "s3a://${module.s3_data_lake.bucket_name}/raw/"
        }
      }
    }
  }

  depends_on = [
    aws_s3_object.flink_jar
  ]
}
