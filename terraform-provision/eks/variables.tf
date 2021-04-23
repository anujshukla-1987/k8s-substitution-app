variable "region" {
  default = "eu-west-1"
}

variable "enable_ssh" {
  type = bool
  default = true
}

variable "sshkey" {
  default = "ashuklakey"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::835483671006:user/ashukla"
      username = "Anuj"
      groups   = ["system:masters"]
    }

  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "deploy role of code pipeline"
      groups   = ["system:masters"]
    },
  ]
}

locals {
  
  asg_tags = [ 
  {
     "key": "k8s.io/cluster-autoscaler/enabled",
     "propagate_at_launch": true,
     "value": true
  },
  {
     "key": "k8s.io/cluster-autoscaler/demo-k8s-cicid-cluster",
     "propagate_at_launch": true,
     "value": "owned"
  }]
  
}
