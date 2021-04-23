# IAM role variables
variable "iam_role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "iam_role_description" {
  type        = string
  description = "Role description"
}

variable "assume_role_policy" {
  description = "[Required] - The AWS entities that can assume the role."
}

variable "iam_role_tags" {
  description = "A map of tags to assign to the role"
  type        = map
  default = {
    terraform = "true"
  }
}
# IAM policy attachment variables
# Define policy ARNs as list
variable "iam_policy_arns" {
  description = "IAM Policy to be attached to role"
  type        = list(string)
}

