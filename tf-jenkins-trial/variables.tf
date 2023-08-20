variable "region" {
  description = "AWS Region in which resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project or Organisation name"
  type        = string
  default     = "ci-in"
}

variable "username" {
  description = "Name of the user"
  type        = string
  default     = "sambhaji"
}


variable "environment" {
  description = "Application environment name (dev/pre-prod/prod)"
  type        = string
  default     = "dev"
}



# variable "compliance" {
#   description = "Compliance Service Provider"
#   type        = string
#   default     = "PCI"
# }

variable "managedBy" {
  description = "Tool used to deploy & manage the code"
  type        = string
  default     = "Terraform"
}

variable "master_ami_id" {
  description = "ami id to use for jenkins master"
  type        = string
  default = "ami-090fa75af13c156b4"
}

/*variable "worker_ami_id" {
  description = "ami id to use for jenkins worker"
  type        = string
}*/

variable "master_instance_type" {
  description = "type of instance to use for jenkins master"
  type        = string
  default = "c1.xlarge"
}

/*variable "worker_instance_type" {
  description = "type of instance to use for jenkins worker"
  type        = string
}*/

variable "key_pair" {
  description = "key pair to use for ec2"
  type        = string
  default = "minikube"
}

variable "master_monitoring" {
  description = "whether to enable ec2 detailed monitoring"
  type        = bool
  default = true
}

variable "disable_api_termination" {
  description = "whether to disable api termination"
  type        = bool
  default = false
}

variable "master_private_ip" {
  description = "private ip of jenkins master"
  type        = string
  default = "10.0.128.15"
}

variable "root_volume_type" {
  description = "type of root volume"
  type        = string
  default = "io1"
}

variable "root_volume_size" {
  description = "size of root volume"
  type        = number
  default = 8
}

variable "root_volume_iops" {
  description = "iops for root volume"
  type        = number
  default = 100
}

variable "vpc_id" {
  description = "vpc id where resources will be deployed"
  type        = string
  default = "vpc-01cc6e49a09d17a4d"
}

variable "public_subnets" {
  description = "ids of public subnets"
  type        = list(string)
  default = ["subnet-0a480130542f4fe6a", "subnet-0e00afe1c67c73ea2"]
}

variable "private_subnets" {
  description = "ids of private subnets"
  type        = list(string)
  default = ["subnet-0b374978f405c4cf7", "subnet-07b40ea2997a62f28"]
}

variable "vault_accounts_role_arn" {
  description = "list of vault accounts role for jenkins master"
  type        = list(string)
  default     = ["*"]
}

/*variable "domain_name" {
  description = "domain name for the hosted zone"
  type        = string
}*/


variable "certificate_arn" {
  description = "arn of certificate to attach to ALB"
  type        = string
  default = "arn:aws:acm:us-east-1:085607062564:certificate/aacc6d3b-725f-4846-abc5-b3d00f22a33e"
}

variable "jenkins_domain_name" {
  description = "domain name to use for jenkins server"
  type        = string
  default = "jenkins"
}



/*variable "waf_arn" {
  description = "arn of waf"
  type        = string
}*/
