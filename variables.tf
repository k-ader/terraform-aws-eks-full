#variable "eks" {
#  description = "Values for EKS Cluster creating"
#  type        = any
#}

variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "Desired Kubernetes master version"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from."
  type        = string
  default     = "10.202.0.0/16"
}

variable "vpc_id" {
  description = "vpc id for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet id's where should located EKS cluster"
  type        = list(string)
}

variable "control_plane_allowed_networks" {
  description = "Subnets that allowed access to manage EKS cluster"
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

variable "nodegroups" {
  description = "NodeGroup config map"
  type        = map(any)
  default     = {}
}

variable "log_retention_in_days" {
  type        = number
  description = "How many days keep logs for controlplane"
  default     = 30
}

variable "key_name" {
  description = "ssh key for access to nodegroups"
  type        = string
}

variable "pod_subnet_ids" {
  description = "Pod networks ids"
  type        = list(string)
}

variable "eniconfig_create" {
  description = "Create Eniconfig using kubernetes provider. Will fail if no access to controlplane"
  type        = bool
  default     = false
}

variable "kms_ebs_key_id" {
  description = "The ID of the KMS Key to attach the policy for EBS CSI."
  type        = string
  default     = null
}

variable "alb_internal" {
  description = "Create private alb or not"
  type        = bool
  default     = true
}

variable "alb_certificate_arn" {
  description = "The certificate ARN for alb HTTPS listener"
  type        = string
}

variable "dns_zone_id" {
  description = "Zone id for alb alias creation"
  type        = string
}

variable "controller_well_known_policy_arns" {
  description = "Default EKS cluster policies"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}

variable "controller_custom_iam_policy" {
  description = "Custom policies for EKS controller "
  type        = map(string)
  default = {
    CloudWatch-Policy = "policy_cloudwatch.json"
    EBS-Policy        = "policy_elb.json"
  }
}

variable "node_well_known_policy_arns" {
  description = "Amazon Controlled IAM Policies arn list"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

variable "oidc_config" {

  description = "OIDC configuration settings"
  type        = map(any)
  #  type = map(object({
  #    client_id                     = string
  #    issuer_url                    = string
  #    identity_provider_config_name = string
  #    groups_claim                  = optional(string)
  #    groups_prefix                 = optional(string)
  #    username_claim                = optional(string)
  #    username_prefix               = optional(string)
  #    required_claims               = map(any)
  #  }))
  default = {}
  #  default = {
  #    client_id                     = null
  #    issuer_url                    = null
  #    identity_provider_config_name = null
  #    groups_claim                  = null
  #    groups_prefix                 = null
  #    username_claim                = null
  #    username_prefix               = null
  #    required_claims               = {}
  #  }
}

variable "irsa_create_autoscaler" {
  description = "Create IRSA for Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "irsa_create_alb_controller" {
  description = "Create IRSA for ALB controllerr"
  type        = bool
  default     = true
}

variable "irsa_create_eso" {
  description = "Create IRSA for External Secrets Operator"
  type        = bool
  default     = false
}

variable "irsa_create_gen_dashboard" {
  description = "Create IRSA for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "irsa_custom" {
  description = <<EOF
    Custom IRSA.
    object with next values:
      path = path for policy, default = "/"
      policy_file = json template (optional). with variables "eks_name" and "account_id", can be empty if AWS managed policy set
      managed_policy_arn = ARN (optional) , can be empty if policy_file set
      service_account = name of service account for IAM authentication
      namespace = namespace where ServiceAccount will be created
  EOF
  type        = any
  default     = null
}

variable "latest_addon_version" {
  description = "true to use latest addon version or false to use current verion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags. For all resources."
  type        = map(string)
  default     = {}
}

variable "tags_oidc" {
  description = "(Optional) Key-value map of resource tags. Additional tags for OIDC provider."
  type        = map(string)
  default     = {}
}

variable "tags_irsa" {
  description = "(Optional) Key-value map of resource tags. Additional tags for IRSA."
  type        = map(string)
  default     = {}
}

variable "tags_alb" {
  description = "(Optional) Key-value map of resource tags. Additional tags for ALB"
  type        = map(string)
  default     = {}
}

variable "tags_nodegroup" {
  description = "(Optional) Key-value map of resource tags. Additional tags for Node Groups"
  type        = map(string)
  default     = {}
}
