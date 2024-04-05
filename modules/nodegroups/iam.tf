resource "aws_iam_role" "nodegroup_role" {
  for_each = var.nodegroups

  name = "${var.name}-${each.key}-InstanceRole"
  assume_role_policy = templatefile("${path.module}/../../files/role_assume_svc.json.tpl",
    {
      service = "ec2.amazonaws.com"
    }
  )
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "nodegroup_policies" {
  for_each   = local.iam_role_and_policy_map
  role       = each.value.iam_role
  policy_arn = each.value.iam_policy
}
