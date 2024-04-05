locals {
  az_available = [ # get AZ from available subnets
    for subnet in data.aws_subnet.subnets :
    subnet.availability_zone
  ]

  iam_role_and_policy_map = {
    for pair in flatten([
      for role in aws_iam_role.nodegroup_role : [
        for policy in var.node_well_known_policy_arns : {
          iam_role   = role["name"]
          iam_policy = policy
        }
      ]
    ]) : "${pair["iam_role"]}_${pair["iam_policy"]}" => pair
  }

  full_map_of_nodegroups = {
    for key, value in var.nodegroups :
    key => merge(
      value,
      {
        ng_name           = "${var.name}-${key}-${element(local.az_available, value["zone_idx"])}-ng"
        role_arn          = aws_iam_role.nodegroup_role[key].arn
        availability_zone = element(local.az_available, value["zone_idx"])
        subnet_id         = element(var.subnet_ids, value["zone_idx"])
      }
    )
  }

  autoscaler_tags = {
    "kubernetes.io/cluster/${var.name}"                        = "owned"
    "k8s.io/cluster-autoscaler/enabled"                        = true
    "k8s.io/cluster-autoscaler/${var.name}"                    = "owned"
    "k8s.io/cluster-autoscaler/node-template/label/kubesystem" = true
  }
}
