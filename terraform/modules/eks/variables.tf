variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  default     = "EKS-vpc"
  description = "EKS-vpc"
}

variable "eks_node_group_name" {
  default     = "eks_node_group_name"
  description = "eks_node_group_name"
}

variable "eks_iam_role_name" {
  default     = "eks_iam_role_name"
  description = "eks_node_group_name"
}

variable "eks_key_pair" {
  default     = "eks_key_pair"
  description = "eks_key_pair"
}

variable "vpc_id" {
  default     = "vpc_id"
  description = "vpc_id"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "10.0.0.0/16"
}

variable "cidr_all" {
  default     = "0.0.0.0/0"
  description = "0.0.0.0/0"
}
variable "eks_desired_worker_node" {
  default     = 2
  description = "eks_desired_worker_node"
}

variable "eks_min_worker_node" {
  default     = 2
  description = "eks_desired_worker_node"
}
variable "eks_max_worker_node" {
  default     = 2
  description = "eks_desired_worker_node"
}

variable "eks_worker_node_instance_type" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "t3.medium"
}

variable "eks_version" {
  default     = "1.29"
  description = "1.29"
}
