
variable "aws_trigram" {}
variable "aws_keypair" {}
# variable "public_ssh_key" {}

variable "env" {
    default = "demo"
}
variable "git_repository" {
    default = "https://github.com/ylascombe/ansible-pull-demo.git"
}
variable "web_role_secret" {}
variable "db_role_secret" {}
