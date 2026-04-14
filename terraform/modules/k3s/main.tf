data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "k3s" {
  name        = "k3s-sg"
  description = "Security group for single node k3s"
  vpc_id      = var.vpc_id

  # SSH via EC2 Instance Connect Endpoint only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.eic_sg_id]
  }

  # k3s API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # flannel VXLAN
  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # NodePort services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

resource "aws_instance" "k3s" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Pre-allow SSH before k3s modifies iptables
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

    # Install k3s using bundled iptables to avoid conflicts with Ubuntu 24.04's nftables
    curl -sfL https://get.k3s.io | sh -s - --prefer-bundled-bin

    # Wait for k3s to fully start and finish writing its iptables rules
    until kubectl get nodes 2>/dev/null | grep -q "Ready"; do sleep 5; done

    # Re-insert SSH rule at the top after k3s has rewritten its chains
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

    # Persist so the rule survives reboots
    apt-get install -y iptables-persistent
    netfilter-persistent save

    # Allow ubuntu user to use kubectl without sudo
    mkdir -p /home/ubuntu/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
    chmod 600 /home/ubuntu/.kube/config
  EOF

  tags = {
    Name = "k3s"
  }
}
