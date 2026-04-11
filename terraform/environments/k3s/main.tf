provider "aws" {
  region  = "us-east-1"
  profile = "tennis"
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

data "aws_security_group" "eic_endpoint" {
  tags = { Name = "eic-endpoint-sg" }
}

module "k3s" {
  source    = "../../modules/k3s"
  vpc_id    = data.aws_vpc.main.id
  subnet_id = data.aws_subnet.private.id
  key_name  = data.aws_key_pair.tennislineup.key_name
  eic_sg_id = data.aws_security_group.eic_endpoint.id
}
