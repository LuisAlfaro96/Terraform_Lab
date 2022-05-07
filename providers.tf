terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS in specific
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/luis/.aws/credentials"
  profile                 = "visual-user" #user created on the AWS Console to manage all the interactions with the AWS  Services.

}