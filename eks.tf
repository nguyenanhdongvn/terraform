/* terraform {
  backend "s3" {
    bucket = "nad-test-backend-terraform-lab"
    key    = "tfstate"  # Đường dẫn lưu trạng thái trong bucket S3
    region = "us-east-1"
    encrypt = true                      # Bật mã hóa cho file trạng thái
    dynamodb_table = "terraform-locks"  # Tên DynamoDB table để quản lý trạng thái khóa
    acl    = "bucket-owner-full-control" # Quyền truy cập (có thể thay đổi)
  }
} */

provider "aws" {
  region = var.region
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}-${var.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.cluster_sg.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
  }

  depends_on = [aws_cloudwatch_log_group.cloudwatch_log_group]

  enabled_cluster_log_types = ["api", "audit"]
}

# EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config  {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size  
  }

  update_config {
    max_unavailable_percentage = 20
  }

  instance_types = [var.instance_type]
}

# Create Addons for EKS Cluster
resource "aws_eks_addon" "addons" {
  for_each                = { for addon in var.addons : addon.name => addon }
  cluster_name            = "${var.cluster_name}-${var.environment}-cluster"
  addon_name              = each.value.name
  addon_version           = each.value.version
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

# Create cloudwatch log group retention for EKS control plane
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}-${var.environment}-cluster/cluster"
  retention_in_days = 30
}