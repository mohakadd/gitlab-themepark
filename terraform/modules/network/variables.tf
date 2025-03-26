variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "CIDR range of the VPC"
}

variable "network_name" {
  default = "EKS-vpc"
  description = "EKS-vpc"
}

variable "pubsn_cidr" {
  default = "10.0.0.0/24"
}

variable "prisn1_cidr" {
  default = "10.0.1.0/24"
}

variable "prisn2_cidr" {
  default = "10.0.2.0/24"
}

variable "cidr_all" {
  default     = "0.0.0.0/0"
}

variable "public_az" {
  default     = "eu-west-3a"
}

variable "private_abz1" {
  default     = "eu-west-3a"
}

variable "private_abz2" {
  default     = "eu-west-3b"
}
