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

variable "environment" {
  type        = string
  description = "Name of environment"
  default     = "staging"  
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"  
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
  default     = "moovtek"
}

variable "cluster_version" {
  type        = string
  description = "The version of the EKS cluster."
  default     = "1.28"
}

variable "scaling_config" {
  type        = object({
    desired_size = number
    max_size     = number
    min_size     = number 
    }
  )
  description = "number of worker node"
   default     = {
    desired_size = 6
    max_size     = 10
    min_size     = 6  
  }
}

variable "instance_type" {
  type        = string
  description = "instance type of worker node"
  default     = "t2.large"
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "kube-proxy"
      version = "v1.28.15-eksbuild.4"
    },
    {
      name    = "vpc-cni"
      version = "v1.19.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.4"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.25.0-eksbuild.1"
    },
    {
      name    = "amazon-cloudwatch-observability"
      version = "v2.5.0-eksbuild.1"
    }    
  ]
}