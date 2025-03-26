terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.network_name}-VPC"
  }
}

resource "aws_internet_gateway" "igw0" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.network_name}-igw0"
  }
}

resource "aws_subnet" "public_sn_01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pubsn_cidr
  map_public_ip_on_launch = true
  availability_zone = var.public_az
  tags = {
    Name = "public_sub_01"
  }
}

resource "aws_subnet" "private_sn_01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block        = var.prisn1_cidr
  availability_zone = var.private_abz1

  tags = {
    Name  = "private_sn_01"
  }

}


resource "aws_subnet" "private_sn_02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.prisn2_cidr
  availability_zone = var.private_abz2
  tags = {
    Name  = "private_sn_02"
  }
}

#route table Creation
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.cidr_all
    gateway_id = aws_internet_gateway.igw0.id
  }
  tags = {
    Name = "public_routetable"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.cidr_all
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private_routetable"
  }

}
#route table association with subnets
resource "aws_route_table_association" "public_rta_01" {
  subnet_id      = aws_subnet.public_sn_01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_01" {
  subnet_id      = aws_subnet.private_sn_01.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_02" {
  subnet_id      = aws_subnet.private_sn_02.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_sn_01.id

  tags = {
    Name  = "nat_gw"
  }

}
resource "aws_eip" "eip" {
  tags = {
    Name  = "my_eip"
  }
}
