# Nodegroup Launch Template
resource "aws_launch_template" "eks_node" {
  for_each      = local.full_map_of_nodegroups
  name          = "${var.name}-${each.key}-ng"
  image_id      = data.aws_ami.eks_node_ami.id
  key_name      = var.key_name #data.aws_key_pair.current.key_name
  ebs_optimized = true
  lifecycle {
    ignore_changes = [
      image_id,
    ]
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = data.aws_ami.eks_node_ami.root_device_name
    ebs {
      encrypted   = "true"
      iops        = "3000"
      kms_key_id  = var.kms_ebs_key_id
      throughput  = "125"
      volume_size = lookup(each.value, "disk_size", null) == null ? 80 : each.value["disk_size"]
      volume_type = "gp3"
    }
  }
  user_data = base64encode(
    templatefile("${path.module}/../../files/userdata.sh.tpl",
      {
        cluster_endpoint  = var.eks_endpoint
        cluster_ca        = var.eks_ca_cert
        cluster_name      = var.name
        service_ipv4_cidr = cidrhost(var.service_ipv4_cidr, 10)
      }
    )
  )

  vpc_security_group_ids = [
    aws_security_group.nodegroup_shared.id,
    var.eks_security_group_id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "2"
    http_tokens                 = "required"
  }

  dynamic "tag_specifications" {
    for_each = ["instance", "volume"]
    content {
      resource_type = tag_specifications.value
      tags = merge(
        var.tags,
        local.autoscaler_tags,
        {
          Name = each.value["ng_name"]
        },
        {
          for key, value in each.value["labels"] :
          "k8s.io/cluster-autoscaler/node-template/label/${key}" => value
        }
      )
    }
  }
  tags = merge(
    var.tags,
    local.autoscaler_tags,
    {
      "eks:cluster-name"   = var.name
      "eks:nodegroup-name" = each.value["ng_name"]
    }
  )
}

resource "aws_eks_node_group" "asg" {
  for_each = local.full_map_of_nodegroups

  capacity_type  = upper(each.value["type"])
  instance_types = toset(flatten([each.value["instance_type"]]))
  cluster_name   = var.name
  labels = merge(
    each.value["labels"],
    {
      instance = each.value["type"]
  })

  dynamic "taint" {
    for_each = lookup(each.value, "taints", {})
    content {
      key    = taint.key
      value  = taint.value.operator
      effect = taint.value.effect
    }
  }
  launch_template {
    name    = aws_launch_template.eks_node[each.key].name
    version = aws_launch_template.eks_node[each.key].latest_version
  }
  node_group_name = each.value["ng_name"]
  node_role_arn   = aws_iam_role.nodegroup_role[each.key].arn
  subnet_ids      = [each.value["subnet_id"]]

  scaling_config {
    desired_size = lookup(each.value, "desired", each.value["min"])
    max_size     = each.value["max"]
    min_size     = each.value["min"]
  }
  update_config {
    max_unavailable_percentage = 25
  }
  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    local.autoscaler_tags,
    {
      "eks:cluster-name"   = var.name
      "eks:nodegroup-name" = each.value["ng_name"]
    }
  )
}
