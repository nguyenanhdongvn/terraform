# create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "${var.cluster_name}-${var.enviroment}-cluster"
#  role_arn = aws_iam_role.eks_cluster_role.arn
  role_arn = var.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
#    subnet_ids         = aws_subnet.eks_subnet[*].id
    subnet_ids         = var.eks_subnet[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }  
}

# Create EKS Node Group
resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id

  scaling_config  = var.scaling_config

  update_config {
    max_unavailable_percentage = 20
  }

  instance_types = [var.instance_type]
}

# Create Addons for EKS Cluster
resource "aws_eks_addon" "addons" {
  for_each                = { for addon in var.addons : addon.name => addon }
  cluster_name            = var.cluster_name
  addon_name              = each.value.name
  addon_version           = each.value.version
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks
  ]
}