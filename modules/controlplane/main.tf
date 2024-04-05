##### IAM
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name}-Cluster-Role"
  assume_role_policy = templatefile("${path.module}/../../files/role_assume_svc.json.tpl",
    {
      service = "eks.amazonaws.com"
    }
  )
}

resource "aws_iam_policy" "eks_cluster_additional_policy" {
  for_each = var.controller_custom_iam_policy

  name   = "${var.name}-${each.key}"
  path   = "/"
  policy = file("${path.module}/../../files/${each.value}")
}

resource "aws_iam_role_policy_attachment" "custom_iam_policy" {
  for_each = aws_iam_policy.eks_cluster_additional_policy

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value["arn"]
}

resource "aws_iam_role_policy_attachment" "well_knwown_policy" {
  for_each = toset(var.controller_well_known_policy_arns)

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
  depends_on = [aws_iam_role_policy_attachment.custom_iam_policy]
}

##### KMS
resource "aws_kms_key" "eks" {
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}
#
resource "aws_kms_alias" "eks" {
  name          = "alias/${var.name}/secrets"
  target_key_id = aws_kms_key.eks.key_id
}

##### Security Group
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.name}-cluster-ServiceRole-"
  description = "ControlPLaneSecurityGroup"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-cluster-ServiceRole",
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

## SG Rules
resource "aws_vpc_security_group_ingress_rule" "eks_api_access" {
  security_group_id = aws_security_group.eks_cluster.id

  count       = length(local.ingress_cidrs)
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = local.ingress_cidrs[count.index]
  description = "Allow https to EKS ControlPlane"
}

resource "aws_vpc_security_group_egress_rule" "eks_egress" {
  security_group_id = aws_security_group.eks_cluster.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
  description       = "Allow all outbound"
}

##### CloudWatch Log Group
#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "eks_controlplane_cloudwatch" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention_in_days
}

##### EKS Controller
resource "aws_eks_cluster" "main" {
  name                      = var.name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  version                   = var.eks_version
  enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = var.private_subnet_ids
  }

  tags = merge(
    var.tags,
    {
      Name = var.name,
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.custom_iam_policy,
    aws_iam_role_policy_attachment.well_knwown_policy,
    aws_cloudwatch_log_group.eks_controlplane_cloudwatch
  ]
}

##### OIDC provider

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  depends_on      = [aws_eks_cluster.main]

  tags = merge(
    var.tags,
    {
      Name = var.name,
    }
  )
}
