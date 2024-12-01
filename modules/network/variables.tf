variable "region" {
  type        = string
  description = "The AWS region for the provider to deploy resources into."
  default     = "us-east-1"
}

variable "az" {
  type        = list(string)
  description = "Availability Zone"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"] 
}

variable "env" {
  type        = string
  description = "Name of environment"
  default     = "stagging"  
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"  
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
  default     = "eks"
}
