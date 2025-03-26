provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "http" {} 
  #backend "s3" {
  #  bucket                  = "terraform-website-app"
  #  key                     = "Lepro-dev.tfstate"
  #  region                  = "eu-west-3"
  #}
}


variable "cluster_name" {
  description = "theme-park cluster name"
  type        = string
  default     = "theme1"  # Default value  (optional)
}

module "network" {
  source                   = "./modules/network"
  network_name             = var.cluster_name
  vpc_cidr                 = "10.0.0.0/16"
  pubsn_cidr               = "10.0.0.0/24"
  prisn1_cidr              = "10.0.1.0/24"
  prisn2_cidr              = "10.0.2.0/24"
  cidr_all                 = "0.0.0.0/0"
  public_az                = "eu-west-3a"
  private_abz1             = "eu-west-3a"
  private_abz2             = "eu-west-3b"
}

module "eks" {
  source                     = "./modules/eks"
  cluster_name               = var.cluster_name
  eks_version                = "1.30"
  eks_iam_role_name          = "EKSClusterRole"
  eks_node_group_name        = "NodeGroup01"
  vpc_id                     = module.network.vpc_id
  vpc_cidr                   = "10.0.0.0/16"
  cidr_all                   = "0.0.0.0/0"
  eks_desired_worker_node    = 2
  eks_min_worker_node        = 1
  eks_max_worker_node        = 7
  eks_worker_node_instance_type = ["t3.medium"]
  eks_key_pair               = "ec2-ansible"
  subnet_ids          = module.network.private_subnet_ids
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

