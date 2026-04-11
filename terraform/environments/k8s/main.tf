provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  tags = { Name = "k8s" }
}

data "aws_subnet" "private" {
  tags = { Name = "k8s-private" }
}

data "aws_key_pair" "tennislineup" {
  key_name = "tennislineup"
}

module "k8s" {
  source    = "../../modules/k8s"
  vpc_id    = data.aws_vpc.main.id
  subnet_id = data.aws_subnet.private.id
  key_name  = data.aws_key_pair.tennislineup.key_name
  my_ip     = var.my_ip
}
