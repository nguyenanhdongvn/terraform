output "eks_subnet" {
  value = aws_subnet.eks_subnet[*].id
}