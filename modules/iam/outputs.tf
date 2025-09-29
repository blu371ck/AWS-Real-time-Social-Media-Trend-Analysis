output "flink_role_arn" {
  value = aws_iam_role.flink_role.arn
}

output "ec2_ssm_role_name" {
  value = aws_iam_role.ec2_ssm_role.name
}