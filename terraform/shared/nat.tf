data "aws_ami" "nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }
}

resource "aws_security_group" "nat" {
  name        = "nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main_tennis.id

  # Allow all traffic from private subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.0/24"]
  }

  # SSH via EIC endpoint
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eic_endpoint.id]
  }

  # Allow all outbound to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-instance-sg"
  }
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nat.id
  instance_type               = "t4g.micro"
  subnet_id                   = aws_subnet.tennis_public.id
  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.tennislineup.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Enable IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/99-nat.conf
    sysctl -p /etc/sysctl.d/99-nat.conf

    # Install and configure nftables
    dnf install -y nftables
    systemctl enable nftables
    systemctl start nftables

    # Add NAT masquerade rule
    nft add table ip nat
    nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
    nft add rule ip nat postrouting oifname "ens5" masquerade

    # Persist rules across reboots
    nft list ruleset > /etc/sysconfig/nftables.conf
  EOF

  tags = {
    Name = "nat-instance"
  }
}

# Route table for private subnet — sends outbound traffic through NAT instance
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_tennis.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = {
    Name = "k8s-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.tennis_private.id
  route_table_id = aws_route_table.private.id
}
