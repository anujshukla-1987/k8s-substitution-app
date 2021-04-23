output "policy_id" {
  value       = aws_iam_policy.this_policy.id
  description = "The ID of the policy."
}

output "policy_arn" {
  value       = aws_iam_policy.this_policy.arn
  description = "The ARN of the policy."
}

output "policy_name" {
  value       = aws_iam_policy.this_policy.name
  description = "The name of the policy."
}

output "policy_document" {
  value       = aws_iam_policy.this_policy.policy
  description = "The JSON formated policy document."
}

