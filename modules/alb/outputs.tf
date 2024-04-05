output "target_group" {
  description = "Target Group group parameters"
  value = {
    "target_group_arn"  = aws_lb_target_group.nodegroup.arn
    "target_group_name" = aws_lb_target_group.nodegroup.name
    "target_group_port" = aws_lb_target_group.nodegroup.port
  }
}

output "alb" {
  description = "Application Load Balancer parameters"
  value = {
    "aws_lb_arn"  = aws_lb.eks.arn
    "aws_lb_name" = aws_lb.eks.name
    "aws_lb_url"  = aws_lb.eks.dns_name
  }
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}
