terraform {
  backend "s3" {
    bucket = "ansiblepulldemo-terraform"
    key    = "ansiblepulldemo.tfstate"
    region = "eu-west-1"
  }
}
