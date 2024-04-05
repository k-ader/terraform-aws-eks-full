variable "vpc_id" {
  description = "vpc id for EKS cluster"
  type        = string
}

variable "local_networks" {
  description = "Subnets that allowed access to manage EKS cluster"
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

variable "ssh_key_name" {
  description = "SSH Key for accessing to Nodegroup hosts"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "EBS KMS key id for encryption/decryption of ebs disks for nodegroups. Use default AWS key"
  type        = string
  default     = null
}

variable "pod_subnet_ids" {
  description = "Pod subnet id's for custom CNI usage"
  type        = list(string)
  default     = null
}

variable "private_subnet_ids" {
  description = "Private subnet id's for custom Nodegroup and ALB location"
  type        = list(string)
  default     = null
}

variable "certificate_arn" {
  description = "Certificate ARN for HTTPS listener in ALB"
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Route53 zone id, for creating rule forward all hosts to alb"
  type        = string
  default     = null
}

variable "eks" {
  description = "Most complicated object variable"
  type        = any
  default = {
    name            = "dev-eks-01"
    version         = "1.27"
    private_cluster = true
    tags = {
      TICKET = "JIRA-TICKET"
      env    = "dev"
    }
    irsa = {
      irsa_create_autoscaler     = true
      irsa_create_alb_controller = true
      irsa_create_eso            = true
      irsa_create_gen_dashboard  = true
      irsa_custom = {
        ESO_1 = {
          namespace       = "*"
          service_account = "external-secrets-ESO"
          policy_file     = "/data/iam/irsa/policy/eso.json"
        }
      }
    }
    oidc_config = {
      client_id                     = "test_oidc"
      issuer_url                    = "https://contoso.com"
      identity_provider_config_name = "Microsoft"
      groups_claim                  = "groups",
      username_claim                = "email",
    }
    node_pools = {
      system-0a = {
        min           = 1
        max           = 3,
        desired       = 1
        type          = "on_demand",
        instance_type = ["m6a.2xlarge"]
        disk_size     = 80
        zone          = "a",
        labels = {
          kubesystem = true
          monitoring = true
        }
      }
      system-0a = {
        min           = 1
        max           = 3,
        desired       = 1
        type          = "on_demand",
        instance_type = ["r6a.2xlarge"]
        disk_size     = 80
        zone          = "a",
        labels = {
          application = true
        }
        taints = {
          application = {
            operator = "Exists"
            effect   = "NO_SCHEDULE"
          }
        }
      }
      build-0a = {
        min     = 0
        max     = 3,
        desired = 0
        type    = "spot",
        instance_type = [
          "m7a.2xlarge",
          "r7a.2xlarge",
          "m6a.2xlarge",
          "r6a.2xlarge",
          "m7a.4xlarge",
          "r7a.4xlarge"
        ]
        disk_size = 80
        zone      = "a",
        labels = {
          build = true
        }
      }
    }
  }
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
