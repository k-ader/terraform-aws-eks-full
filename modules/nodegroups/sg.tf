resource "aws_security_group" "nodegroup_shared" {
  name_prefix = "${var.name}-nodegroup-shared-"
  description = "Nodegroup shared security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

# ToDo: This part already exists in eks security group and can be removed after probation.
resource "aws_vpc_security_group_ingress_rule" "node_shared" {
  description                  = "Allow nodes to communicate with each other (all ports)"
  security_group_id            = aws_security_group.nodegroup_shared.id
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.nodegroup_shared.id
}

resource "aws_vpc_security_group_ingress_rule" "remote_access" {
  description       = "Allow SSH access to managed worker nodes in group"
  security_group_id = aws_security_group.nodegroup_shared.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_vpc.eks.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "alb_access" {
  description                  = "Allow SSH access to managed worker nodes in group"
  security_group_id            = aws_security_group.nodegroup_shared.id
  from_port                    = 20000
  to_port                      = 36000
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.alb_security_group_id

}

resource "aws_vpc_security_group_egress_rule" "eks_egress" {
  description       = "Allow all outbound"
  security_group_id = aws_security_group.nodegroup_shared.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}
