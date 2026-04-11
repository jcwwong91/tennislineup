resource "aws_key_pair" "tennislineup" {
  key_name   = "tennislineup"
  public_key = var.public_key
}
