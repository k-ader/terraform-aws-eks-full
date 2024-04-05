<!-- BEGIN_TF_DOCS -->
# terraform-eks-full
## Create EKS cluster with Controller, Managed Nodegroups and add-ons

### Steps to create for Controller:
 1. IAM Role
 2. KMS Key
 3. Security Group
 4. Logs stream in CloudWatch
 5. Control Plane

### Steps to create Nodegroups
 1. IAM Role
 2. Security Group
 3. Autoscale Launch Template
 4. EKS NodeGroup ASG from template

### Steps to create addons:
#### VPC-CNI
 1. IAM Role
 2. EBS CNI Driver
NB! VPC-CNI set to use custom VPC for pod networks. Eniconfig is needed.
ToDo: Add eniconfig by applying kubectl apply -f ENICONFIG.yaml
NB! Node system ASG refresh needed.

#### EBS-CSI
 1. IAM Role
 2. EBS CSI Driver
 3. Add EBS SCI Driver ARN to default EBS KMS Key users

#### CoreDNS
 1. coredns deployment

#### Kube-proxy
 1. kube-proxy deployment

#### Iam Roles for Service Accounts
 1. Create default IRSA if enabled: Autoscaler, ALB Controller, External Secrets Operator, Dashboard.
 2. Custom IRSA if set (available variables for template: "eks\_name" and "account\_id")

#### Custom OIDC
 1. Create Additional custom OIDC provider if set.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.32 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.7 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >=4.0 |

## Usage
Basic usage of this module is as follows:
```hcl
  module "example" {
    	 source  = "<path-to-module>"
        
	 # Required variables
        	 alb_certificate_arn  = ""
        	 dns_zone_id  = ""
        	 eks_version  = ""
        	 key_name  = ""
        	 name  = ""
        	 pod_subnet_ids  = ""
        	 private_subnet_ids  = ""
        	 vpc_id  = ""
}
```

## Resources

| Name | Type |
|------|------|
| [aws_ebs_default_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ebs_default_kms_key) | data source |
| [aws_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | The certificate ARN for alb HTTPS listener | `string` | n/a | yes |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Create private alb or not | `bool` | `true` | no |
| <a name="input_control_plane_allowed_networks"></a> [control\_plane\_allowed\_networks](#input\_control\_plane\_allowed\_networks) | Subnets that allowed access to manage EKS cluster | `list(string)` | <pre>[<br>  "10.0.0.0/8",<br>  "172.16.0.0/12",<br>  "192.168.0.0/16"<br>]</pre> | no |
| <a name="input_controller_custom_iam_policy"></a> [controller\_custom\_iam\_policy](#input\_controller\_custom\_iam\_policy) | Custom policies for EKS controller | `map(string)` | <pre>{<br>  "CloudWatch-Policy": "policy_cloudwatch.json",<br>  "EBS-Policy": "policy_elb.json"<br>}</pre> | no |
| <a name="input_controller_well_known_policy_arns"></a> [controller\_well\_known\_policy\_arns](#input\_controller\_well\_known\_policy\_arns) | Default EKS cluster policies | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",<br>  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"<br>]</pre> | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | Zone id for alb alias creation | `string` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | Desired Kubernetes master version | `string` | n/a | yes |
| <a name="input_eniconfig_create"></a> [eniconfig\_create](#input\_eniconfig\_create) | Create Eniconfig using kubernetes provider. Will fail if no access to controlplane | `bool` | `false` | no |
| <a name="input_irsa_create_alb_controller"></a> [irsa\_create\_alb\_controller](#input\_irsa\_create\_alb\_controller) | Create IRSA for ALB controllerr | `bool` | `true` | no |
| <a name="input_irsa_create_autoscaler"></a> [irsa\_create\_autoscaler](#input\_irsa\_create\_autoscaler) | Create IRSA for Cluster Autoscaler | `bool` | `true` | no |
| <a name="input_irsa_create_eso"></a> [irsa\_create\_eso](#input\_irsa\_create\_eso) | Create IRSA for External Secrets Operator | `bool` | `false` | no |
| <a name="input_irsa_create_gen_dashboard"></a> [irsa\_create\_gen\_dashboard](#input\_irsa\_create\_gen\_dashboard) | Create IRSA for Cluster Autoscaler | `bool` | `false` | no |
| <a name="input_irsa_custom"></a> [irsa\_custom](#input\_irsa\_custom) | Custom IRSA.<br>    object with next values:<br>      path = path for policy, default = "/"<br>      policy\_file = json template (optional). with variables "eks\_name" and "account\_id", can be empty if AWS managed policy set<br>      managed\_policy\_arn = ARN (optional) , can be empty if policy\_file set<br>      service\_account = name of service account for IAM authentication<br>      namespace = namespace where ServiceAccount will be created | `any` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | ssh key for access to nodegroups | `string` | n/a | yes |
| <a name="input_kms_ebs_key_id"></a> [kms\_ebs\_key\_id](#input\_kms\_ebs\_key\_id) | The ID of the KMS Key to attach the policy for EBS CSI. | `string` | `null` | no |
| <a name="input_latest_addon_version"></a> [latest\_addon\_version](#input\_latest\_addon\_version) | true to use latest addon version or false to use current verion | `bool` | `false` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | How many days keep logs for controlplane | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | EKS cluster name | `string` | n/a | yes |
| <a name="input_node_well_known_policy_arns"></a> [node\_well\_known\_policy\_arns](#input\_node\_well\_known\_policy\_arns) | Amazon Controlled IAM Policies arn list | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",<br>  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",<br>  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",<br>  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",<br>  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"<br>]</pre> | no |
| <a name="input_nodegroups"></a> [nodegroups](#input\_nodegroups) | NodeGroup config map | `map(any)` | `{}` | no |
| <a name="input_oidc_config"></a> [oidc\_config](#input\_oidc\_config) | OIDC configuration settings | `map(any)` | `{}` | no |
| <a name="input_pod_subnet_ids"></a> [pod\_subnet\_ids](#input\_pod\_subnet\_ids) | Pod networks ids | `list(string)` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Subnet id's where should located EKS cluster | `list(string)` | n/a | yes |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes pod and service IP addresses from. | `string` | `"10.202.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. For all resources. | `map(string)` | `{}` | no |
| <a name="input_tags_alb"></a> [tags\_alb](#input\_tags\_alb) | (Optional) Key-value map of resource tags. Additional tags for ALB | `map(string)` | `{}` | no |
| <a name="input_tags_irsa"></a> [tags\_irsa](#input\_tags\_irsa) | (Optional) Key-value map of resource tags. Additional tags for IRSA. | `map(string)` | `{}` | no |
| <a name="input_tags_nodegroup"></a> [tags\_nodegroup](#input\_tags\_nodegroup) | (Optional) Key-value map of resource tags. Additional tags for Node Groups | `map(string)` | `{}` | no |
| <a name="input_tags_oidc"></a> [tags\_oidc](#input\_tags\_oidc) | (Optional) Key-value map of resource tags. Additional tags for OIDC provider. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id for EKS cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_addon_coredns"></a> [addon\_coredns](#output\_addon\_coredns) | Core DNS add-on parameters |
| <a name="output_addon_ebs_csi"></a> [addon\_ebs\_csi](#output\_addon\_ebs\_csi) | EBS CSI add-on parameters |
| <a name="output_addon_efs_csi"></a> [addon\_efs\_csi](#output\_addon\_efs\_csi) | EFS CSI add-on parameters |
| <a name="output_addon_kube_proxy"></a> [addon\_kube\_proxy](#output\_addon\_kube\_proxy) | Kube proxy add-on parameters |
| <a name="output_addon_vpc_cni"></a> [addon\_vpc\_cni](#output\_addon\_vpc\_cni) | VPC CNI add-on parameters |
| <a name="output_control_plane"></a> [control\_plane](#output\_control\_plane) | Control Plane parameters |
| <a name="output_eniconfig"></a> [eniconfig](#output\_eniconfig) | ENIconfig for kubectl apply parameters. Custom netwirking for pods |
| <a name="output_irsa"></a> [irsa](#output\_irsa) | IAM Roles for Service Accounts |
| <a name="output_kubectl_config_cmd"></a> [kubectl\_config\_cmd](#output\_kubectl\_config\_cmd) | kubectl config command |
| <a name="output_nodegroup"></a> [nodegroup](#output\_nodegroup) | Node Groups parameters and template versions |

<!-- END_TF_DOCS -->
