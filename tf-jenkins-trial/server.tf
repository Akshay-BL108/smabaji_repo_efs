

data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

resource "aws_instance" "jenkins_server" {
  ami                     = var.master_ami_id
  instance_type           = var.master_instance_type
  monitoring              = var.master_monitoring
  key_name                = var.key_pair
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = true
  vpc_security_group_ids  = [aws_security_group.jenkins_master_sg.id]
  subnet_id               = var.private_subnets[0]
  user_data               = templatefile("${path.module}/templates/jenkins_m.sh.tpl", { efs_id = aws_efs_file_system.jenkins_efs.id })
  private_ip              = var.master_private_ip
  //iam_instance_profile    = aws_iam_instance_profile.jenkins_master.name

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    delete_on_termination = false
    encrypted             = true
    kms_key_id            = data.aws_kms_key.ebs.arn
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_iops
  }

  tags = {
    Name      = format("%v-%v-jenkins-master", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }

  depends_on = [
    aws_efs_file_system.jenkins_efs,
    aws_efs_mount_target.mount_target
  ]
}

resource "aws_lb_target_group_attachment" "alb_tg_8080" {
  target_group_arn = aws_lb_target_group.alb_tg_8080.arn
  target_id        = aws_instance.jenkins_server.id
  port             = 8080
  depends_on       = [aws_lb.jenkins_alb]
}
