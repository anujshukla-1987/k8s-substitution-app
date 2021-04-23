terraform {
  backend "s3" {
    bucket         = "eks-terraform-anuj"
    key            = "vpc/vpc.tfstate"
    region         = "eu-west-1"
  }
}
