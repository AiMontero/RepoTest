terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Obtiene la VPC por defecto de la región
data "aws_vpc" "default" {
  default = true
}

# Crea el Security Group solicitado en el ejercicio
resource "aws_security_group" "test_terraform_sg" {
  name        = "test-terraform-sg"
  description = "Permite acceso SSH y salida libre"
  vpc_id      = data.aws_vpc.default.id

  # Regla de entrada: SSH por puerto 22/TCP
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida: cualquier destino
  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-terraform-sg"
  }
}

# Instancia EC2 asociada al SG creado
resource "aws_instance" "mi_ec2" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_terraform_sg.id]

  tags = {
    Name = "test-terraform-ec2"
  }
}
