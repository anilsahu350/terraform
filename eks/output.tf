output "cluster_id" {
  value = aws_eks_cluster.anil.id
}

output "node_group_id" {
  value = aws_eks_node_group.anil.id
}

output "vpc_id" {
  value = aws_vpc.anil_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.anil_subnet[*].id
}

