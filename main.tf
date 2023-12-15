# AWS PROVIDER 

provider "aws" {
  region = "ap-south-1"

}

#  VPC

resource "aws_vpc" "vc_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Viking-VPC"

  }
}

# Public Subnet

resource "aws_subnet" "vc_pub_sub" {
  vpc_id                  = aws_vpc.vc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "Viking-Pub_subnet"
  }
}

#  Private Subnet

resource "aws_subnet" "vc_pri_sub" {
  vpc_id                  = aws_vpc.vc_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false


  tags = {
    Name = "Viking-Priv_subnet"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "vc_nat" {
  allocation_id = aws_eip.vc_eip.id
  subnet_id     = aws_subnet.vc_pub_sub.id

  tags = {
    Name = "Viking-NAT"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "vc_igw" {
  vpc_id = aws_vpc.vc_vpc.id

  tags = {
    Name = "Viking-IGW"
  }
}

# ELASTIC IP ADDRESS

resource "aws_eip" "vc_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.vc_igw]

  tags = {
    Name = "Viking-EIP"
  }
}


# Public Subnet Route table

resource "aws_route_table" "vc_pub_rt" {
  vpc_id = aws_vpc.vc_vpc.id

  tags = {
    Name = "Viking-pub-rt"
  }
}

# Private Subnet Route Table

resource "aws_route_table" "vc_pri_rt" {
  vpc_id = aws_vpc.vc_vpc.id

  tags = {
    Name = "Viking-Pri_rt"
  }
}


# Route for internet Gateway

resource "aws_route" "vc_pub_igw" {
  route_table_id         = aws_route_table.vc_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vc_igw.id
}

# Route for NAT Gateway

resource "aws_route" "vc_pri_ngw" {
  route_table_id         = aws_route_table.vc_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.vc_nat.id

}



# Associate Private Subnet with Private Route Table

resource "aws_route_table_association" "vc_pub_sub_assoc" {
  subnet_id      = aws_subnet.vc_pub_sub.id
  route_table_id = aws_route_table.vc_pub_rt.id
}


resource "aws_route_table_association" "vc_pri-sub-assoc" {
  subnet_id      = aws_subnet.vc_pri_sub.id
  route_table_id = aws_route_table.vc_pri_rt.id
}


# Create Security Group

resource "aws_security_group" "vc_sg" {
  name        = "This security group for the Multiply ports"
  description = "All inbound and Outbounds Rules"
  vpc_id      = aws_vpc.vc_vpc.id

  # Allow incoming TCP requests on Port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 80 from any IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 443 from any IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming TCP requests on port 8080 from any IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Viking-SG"
  }
}