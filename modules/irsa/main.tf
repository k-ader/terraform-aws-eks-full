data "aws_caller_identity" "current" {}

locals {
  well_known_irsa = {
    autoscaler = var.irsa_create_autoscaler == false ? null : {
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
      policy_file     = "${path.module}/../../files/policy_autoscaler.json.tpl"
    }
    alb_controller = var.irsa_create_alb_controller == false ? null : {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
      policy_file     = "${path.module}/../../files/policy_alb_controller.json"
      # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
    }
    eso = var.irsa_create_eso == false ? null : {
      namespace       = "*"
      service_account = "external-secrets-eso"
      policy_file     = "${path.module}/../../files/policy_eso.json.tpl" #"${path.module}/../../files/policy_eso.json.tpl"
    }
    dashboard = var.irsa_create_gen_dashboard == false ? null : {
      namespace       = "monitoring"
      service_account = "gen-dashboard-eso"
      policy_file     = "${path.module}/../../files/policy_gen_dashboard.json.tpl"
    }
  }

  irsa_to_create = merge(
    {
      for key, value in local.well_known_irsa :
      key => value if value != null
    },
    var.irsa_custom
  )

  iam_role_name   = "${var.eks_name}-%s-Role"
  iam_policy_name = "${var.eks_name}-%s-Policy"
}

resource "aws_iam_role" "irsa" {
  for_each = local.irsa_to_create
  name     = format(local.iam_role_name, each.key)
  assume_role_policy = try(
    templatefile("${path.module}/../../files/role_assume_sa.json.tpl", {
      oidc_provider_arn = var.oidc_provider_arn
      oidc_provider_url = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
      namespace         = try(each.value["namespace"], null)
      service_account   = try(each.value["service_account"], null)
    }),
  null)

  tags = var.tags
}
resource "aws_iam_policy" "irsa" {
  for_each = local.irsa_to_create
  name     = try(each.value["policy_file"], null) == null ? null : format(local.iam_policy_name, each.key)
  path     = try(each.value["path"], null)
  policy = try(
    templatefile(each.value["policy_file"], {
      eks_name   = var.eks_name
      account_id = data.aws_caller_identity.current.id
    }),
    null
  )

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each   = local.irsa_to_create
  role       = format(local.iam_role_name, each.key)
  policy_arn = element([for item in aws_iam_policy.irsa : item.arn], index(keys(local.irsa_to_create), each.key))
  depends_on = [
    aws_iam_role.irsa,
    aws_iam_policy.irsa
  ]
}
