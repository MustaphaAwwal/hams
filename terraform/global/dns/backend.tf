terraform {
  backend "s3" {
    bucket         = "hams-terraform-state"
    key            = "global/dns/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hams-terraform-locks"
    encrypt        = true
    profile = "awwal"  # Specify the AWS profile to use
  }
}
