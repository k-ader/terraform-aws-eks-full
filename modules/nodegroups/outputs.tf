output "nodegroup_iam_roles" {
  description = "IAM Roles for Node Groups"
  value = {
    for role in aws_iam_role.nodegroup_role :
    role.name => role.arn
  }
}

output "launch_template_id" {
  description = "Node Group launch template IDs"
  value = {
    for template in aws_launch_template.eks_node :
    template.name => template.id
  }
}

output "launch_template_version" {
  description = "Default launch template current version"
  value = {
    for template in aws_launch_template.eks_node :
    template.name => template.default_version
  }
}

output "nodegroup_template_version" {
  description = "Node Groups running template version"
  value = {
    for nodegroup in aws_eks_node_group.asg :
    nodegroup.node_group_name => nodegroup.launch_template[0].version
  }
}
