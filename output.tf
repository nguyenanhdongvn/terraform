output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "node_group_id" {
  value = aws_eks_node_group.eks_node_group.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}