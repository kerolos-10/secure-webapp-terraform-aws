terraform {
  backend "s3" {
    bucket         = "kerolos-s3-bucket-2025"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
