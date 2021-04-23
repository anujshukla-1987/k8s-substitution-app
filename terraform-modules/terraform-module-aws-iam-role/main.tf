# 1 Create the role with an assume policy
resource "aws_iam_role" "this_role" {
  name        = var.iam_role_name
  description = var.iam_role_description

  # Which AWS entity can assume that role
  assume_role_policy = var.assume_role_policy
  tags               = var.iam_role_tags
}


resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  role       = aws_iam_role.this_role.name
  count      = length(var.iam_policy_arns)
  policy_arn = var.iam_policy_arns[count.index]
}
