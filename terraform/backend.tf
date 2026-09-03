terraform {
  backend "s3" {
    bucket       = "devops-assignment-terraform-state-<unique-number>"
    key          = "devops-assignment/staging/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
