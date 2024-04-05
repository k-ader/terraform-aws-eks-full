data "aws_ami" "eks_node_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amazon-eks-node-${var.eks_version}-*"
    ]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(var.subnet_ids)
  id       = each.key
}

data "aws_vpc" "eks" {
  id = var.vpc_id
}
