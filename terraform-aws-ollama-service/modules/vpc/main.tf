resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.name}-vpc"
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}-igw"
    "Terraform" = true
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.name}-public-${count.index + 1}"
    "Terraform" = true
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    "Name" = "${var.name}-private-${count.index + 1}"
    "Terraform" = true
  }
}

# Main route table

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "main"
  }
}

resource "aws_main_route_table_association" "main_route" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.main.id
}

# Subnet associations of 'main' route table

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.main.id
}

# Add Routes to Internet Gateway

resource "aws_route" "ipv6_route" {
  route_table_id              = aws_route_table.main.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

resource "aws_route" "ipv4_route" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
