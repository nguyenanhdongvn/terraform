variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
  default     = "eks"
}

variable "environment" {
  type        = string
  description = "Name of environment"
  default     = "stagging"  
}

variable "cluster_version" {
  type        = string
  description = "The version of the EKS cluster."
  default     = "1.28"
}

variable "scaling_config" {
  type        = map(number)
  description = "number of worker node"
  default     = {
    desired_size = 3
    max_size     = 10
    min_size     = 3  
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

variable "eks_cluster_role_arn" {
  type = string
}

variable "eks_subnet" {
  type = string
}