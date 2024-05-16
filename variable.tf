# Terraform Variables
# Local Values
locals {
  vpc_name     = "demo-vpc"
  environment  = "development"
}

variable "aws_region" {
  description = "Define the AWS Region"
  type        = string
  default     = "us-east-1"
}

locals {
  az_names = ["${var.aws_region}a", "${var.aws_region}b"]
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "private_subnets_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["172.16.10.0/24", "172.16.11.0/24"]
}

variable "amiID" {
  description ="Specify AMI ID"
  type        = string
  default     = "ami-0e001c9271cf7f3b9"
}
variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
  default     = "t2.micro"
}
