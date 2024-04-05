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
}

variable "nodegroups" {
  description = "NodeGroup config map"
  type        = map(any)
  default     = {}
}

variable "vpc_id" {
  description = "vpc id for EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet id's where should located EKS cluster and nodes"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group id from ALB to allow incoming traffic to the nodes"
  type        = string
  default     = null
}

variable "key_name" {
  description = "SSH key for access to nodegroups"
  type        = string
}

variable "node_well_known_policy_arns" {
  description = "Amazon Controlled IAM Policies arn list"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "The EKS Controller main security group"
  type        = string
}

variable "eks_endpoint" {
  description = "The EKS Controller connection URL"
  type        = string
}

variable "eks_ca_cert" {
  description = "The EKS Controller SSL certificate base 64 encoded"
  type        = string
}

variable "kms_ebs_key_id" {
  description = "The ID of the KMS Key to attach the policy for EBS CSI."
  type        = string
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
