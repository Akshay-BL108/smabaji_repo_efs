data "aws_kms_key" "efs" {
  key_id = "alias/aws/elasticfilesystem"
}

resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = format("%v-%v-jenkins-efs", var.project, var.environment)
  encrypted      = true
  kms_key_id     = data.aws_kms_key.efs.arn

  tags = {
    Name      = format("%v-%v-jenkins-efs", var.project, var.environment)
    CreatedBy = data.aws_caller_identity.current.arn
  }
}

resource "aws_efs_backup_policy" "efs_backup_policy" {
  file_system_id = aws_efs_file_system.jenkins_efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_mount_target_sg.id]
}
