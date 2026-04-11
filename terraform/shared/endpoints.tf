resource "aws_security_group" "eic_endpoint" {
  name        = "eic-endpoint-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main_tennis.id

  # Allow the endpoint to reach port 22 on instances within the VPC
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "eic-endpoint-sg"
  }
}

resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.tennis_private.id
  security_group_ids = [aws_security_group.eic_endpoint.id]

  tags = {
    Name = "tennislineup-eic"
  }
}
