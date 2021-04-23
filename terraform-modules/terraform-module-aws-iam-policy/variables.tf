variable "policy_name" {
  description = "Name of the custom policy"
  type        = string
}
variable "policy_description" {
  description = "Description of the custom policy"
  type        = string
  default     = "Custom policy created with Terraform"
}

variable "policy_document" {
  description = "[Required] - Policy document in JSON format"
}

variable "region" {
  description = "AWS region to use. [Default] - eu-west-1"
  default     = "eu-west-1"
}

