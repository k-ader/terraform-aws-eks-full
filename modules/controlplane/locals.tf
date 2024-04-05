locals {
  ingress_cidrs = concat(tolist(split(", ", data.aws_vpc.eks.cidr_block)), var.control_plane_allowed_networks)
}
