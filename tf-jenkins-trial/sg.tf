locals {
  alb_ports_in = [
    80,
    443
  ]
  alb_ports_out = [
    0
  ]
}

data "aws_security_group" "default_sg" {
  name   = "default"
  vpc_id = var.vpc_id
}


resource "aws_security_group" "jenkins_alb" {
  name        = format("%v-%v-jenkins-alb-sg", var.project, var.environment)
  description = "Security group attached to jenkins loadbalancer"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(local.alb_ports_in)
    content {
      description = "Web Traffic from internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = toset(local.alb_ports_out)
    content {
      description = "Web Traffic to internet"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name      = format("%v-%v-jenkins-alb-sg", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}

resource "aws_security_group" "efs_mount_target_sg" {
  name        = format("%v-%v-efs-mount-target-sg", var.project, var.environment)
  description = "Allow TLS inbound and outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from jenkins master"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id]
  }
  egress {
    description = "Web Traffic to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = format("%v-%v-efs-mount-target-sg", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}


resource "aws_security_group" "jenkins_master_sg" {
  name        = format("%v-%v-jenkins-master-sg", var.project, var.environment)
  description = "Allow TLS inbound and outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = format("%v-%v-jenkins-master-sg", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}

resource "aws_security_group" "jenkins_worker_sg" {
  name        = format("%v-%v-jenkins-worker-sg", var.project, var.environment)
  description = "Allow TLS inbound and outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = format("%v-%v-jenkins-worker-sg", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}
