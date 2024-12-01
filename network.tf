# VPC Configuration
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# Subnet Configuration
# Public Subnet
resource "aws_subnet" "public_subnet" {
  count = 1
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 10)
  availability_zone       = element(var.az, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index + 1}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  availability_zone       = element(var.az, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-${count.index + 1}"
  }
}

## Internet GateWay Configuration
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.cluster_name}-internet_gw"
  }
}

## NAT GateWay Configuraiton
# Public IP for NAT Gateway
resource "aws_eip" "public_ip" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-public_ip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.public_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.cluster_name}-nat_gw"
  }

  depends_on = [aws_internet_gateway.internet_gw]
}

## Route Table configuration
# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-route_table"
  }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.cluster_name}-private-route_table"
  }
}

# Assocciate Public Route Table to Public Subnet
resource "aws_route_table_association" "rt_to_public_subnet" {
  count          = 1
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Assocciate Private Route Table to Private Subnet
resource "aws_route_table_association" "rt_to_private_subnet" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# SG for EKS Cluster
resource "aws_security_group" "cluster_sg" {
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# SG for Node Group
resource "aws_security_group" "node_group_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-group-sg"
  }
}