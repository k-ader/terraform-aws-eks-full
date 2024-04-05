locals {
  manifest = join("\n", concat([
    for networks in data.aws_subnet.pod_networks : <<EOF
---
apiVersion: "crd.k8s.amazonaws.com/v1alpha1"
kind: "ENIConfig"
metadata:
  name: ${networks.availability_zone}
    spec:
      subnet: ${networks.id}
      securityGroups:
        - ${var.eks_security_group_id}
EOF
  ]))

}
