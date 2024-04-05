output "irsa" {
  description = "IAM Roles for Service Accounts"
  value = {
    for role in aws_iam_role.irsa :
    role.name => role.arn
  }
}
