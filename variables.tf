variable "application" {
  default = "tron-full-node"
}

variable "provisionersrc" {
  default = "tron/provisioners"
}

variable "vpc_cidr_block" {
  description = "The VPC CIDR address range"
  default     = "172.31.0.0/16" # we need to get from aws account.
}

variable "slack_webhook_url" {}

variable "tron_count" {
  description = "The amount of Tron Node instances to create"
  default     = 1
}

//variable "vpc_id" {}

variable "instance_type" {
  default = "t2.xlarge"
}

variable "ssh_keypath" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_keypath" {
  default = "~/.ssh/id_rsa"
}

variable "region" {
  default = "us-west-1"
}

variable "aws_profile" {
  default = "default"
}

variable "alarms_email" {}
