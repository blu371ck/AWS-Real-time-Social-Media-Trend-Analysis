resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "reddit-project-vpc"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Explicitly set AZ
  tags = {
    Name = "reddit-project-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24" # Use a different CIDR block
  availability_zone = "us-east-1b" # Use a different AZ
  tags = {
    Name = "reddit-project-private-subnet-b"
  }
}

resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-sg"
  }
}