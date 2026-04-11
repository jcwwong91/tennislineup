# Main VPC to host things
resource "aws_vpc" "main_tennis" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8s"
  }
}

# Public subnet for the internet gateway
resource "aws_subnet" "tennis_public" {
  vpc_id     = aws_vpc.main_tennis.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "k8s-public"
  }
}

# Private Subnet for k8s cluster
resource "aws_subnet" "tennis_private" {
  vpc_id     = aws_vpc.main_tennis.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "k8s-private"
  }
}

# Internet Gateway - connects your VPC to the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_tennis.id

  tags = {
    Name = "k8s-igw"
  }
}

# Route Table - rules for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_tennis.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "k8s-public-rt"
  }
}

# Associate the route table with your public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.tennis_public.id
  route_table_id = aws_route_table.public.id
}
