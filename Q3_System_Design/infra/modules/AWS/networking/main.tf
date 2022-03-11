resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags       = {
        Name = "POC-VPC"
    }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "pub_1_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.10.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "pub_2_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.20.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "priv_1_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.30.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "priv_2_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.40.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table_association" "route_table_public_1" {
    subnet_id      = aws_subnet.pub_1_subnet.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "route_table_public_2" {
    subnet_id      = aws_subnet.pub_2_subnet.id
    route_table_id = aws_route_table.public.id
}

