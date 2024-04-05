variable "vpc_id" {
  description = "vpc id for EKS cluster"
  type        = string
}

variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "alb_internal" {
  description = "ALB internal or external. Boolean. Always true as external not implemented"
  type        = bool
  default     = true
}

variable "alb_delete_protection" {
  description = "ALB deletion protection"
  type        = bool
}

variable "certificate_arn" {
  description = "The certificate ARN for alb HTTPS listener"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ids for ALB"
  type        = list(string)
}

variable "dns_zone_id" {
  description = "Zone id for alb alias creation"
  type        = string
}

variable "connection_termination" {
  description = "Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers"
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the target group. Possible values are ipv4 or ipv6"
  type        = string
  default     = "ipv4"
}

variable "load_balancing_cross_zone_enabled" {
  description = "Indicates whether cross zone load balancing is enabled."
  type        = string
  default     = "use_load_balancer_configuration"
}

variable "port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "protocol_version" {
  description = "Only applicable when protocol is HTTP or HTTPS"
  type        = string
  default     = "HTTP1"
}

variable "proxy_protocol_v2" {
  description = "Whether to enable support for proxy protocol v2 on Network Load Balancers"
  type        = bool
  default     = false
}

variable "slow_start" {
  description = "Amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable"
  type        = number
  default     = 0
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags."
  type        = map(string)
  default     = {}
}
