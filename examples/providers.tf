terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0"
    }
  }
}
