terraform {
  backend "s3" {
    bucket         = "eks-terraform-anuj"
    key            = "eks/eks.tfstate"
    region         = "eu-west-1"
  }
}
