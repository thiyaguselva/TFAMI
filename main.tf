provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

############################### NETWORK PART ####################################
# VPC
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-test-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "tf-test-igw"
  }
}


resource "aws_security_group" "this" {
  name   = "security_group_for_test_sg"
  vpc_id = aws_vpc.this.id

  # this might be a security threat. but for demo purpose we are opening it up for public access for all ports.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tf-test-public-sb"
  }
}

# ROUTE TABLE 1 WITH IGW ATTACHED
resource "aws_route_table" "public-rt" {
  vpc_id     = aws_vpc.this.id
  depends_on = [aws_internet_gateway.this]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "tf-test-public-rt"
  }
}

# PUBLIC SUBNET AND ROUTE TABLE ATTACHED
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.public-rt.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_id" {
  value = aws_subnet.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}