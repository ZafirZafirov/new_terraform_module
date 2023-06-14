###################################################
################### CREATE VPC ####################
###################################################

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}

###################################################
################ CREATE 4 SUBNETS #################
###################################################

resource "aws_subnet" "terraform_sub1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "public1")
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public-subnet-01"
  }
}

resource "aws_subnet" "terraform_sub2" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "public2")
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public-subnet-02"
  }
}

resource "aws_subnet" "terraform_sub3" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "private1")
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-subnet-01"
  }
}

resource "aws_subnet" "terraform_sub4" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = lookup(var.cidr_ranges, "private2")
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-subnet-02"
  }
}


###################################################
################### CREATE IGW ####################
###################################################

resource "aws_internet_gateway" "terraform_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "terraform-gateway"
  }
}

###################################################
############### CREATE 2 ELASTIC IP ###############
###################################################

resource "aws_eip" "terraform_elip" {
  domain = "vpc"
}

resource "aws_eip" "terraform_elip2" {
  domain = "vpc"
}


###################################################
################# CREATE 2 NAT GW #################
###################################################

resource "aws_nat_gateway" "terraform_nat" {
  allocation_id = aws_eip.terraform_elip.id
  subnet_id     = aws_subnet.terraform_sub1.id
  tags = {
    Name = "nat-gateway-01"
  }
}

resource "aws_nat_gateway" "terraform_nat2" {
  allocation_id = aws_eip.terraform_elip2.id
  subnet_id     = aws_subnet.terraform_sub2.id
  tags = {
    Name = "nat-gateway-02"
  }
}

###################################################
############ CREATE 4 ROUTING TABLES ##############
###################################################

resource "aws_route_table" "terraform_route_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_gateway.id
  }
  tags = {
    Name = "gateway-route-table"
  }
}

resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_nat.id
  }
  tags = {
    Name = "nat-01-route-table"
  }
}

resource "aws_route_table" "route_nat2" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_nat2.id
  }
  tags = {
    Name = "nat-02-route-table"
  }
}
###################################################
############ ASSOCIATE ROUTING TABLES #############
###################################################

resource "aws_route_table_association" "terraform_associate1" {
  subnet_id      = aws_subnet.terraform_sub1.id
  route_table_id = aws_route_table.terraform_route_gateway.id
}

resource "aws_route_table_association" "terraform_associate2" {
  subnet_id      = aws_subnet.terraform_sub2.id
  route_table_id = aws_route_table.terraform_route_gateway.id
}

resource "aws_route_table_association" "terraform_associate3" {
  subnet_id      = aws_subnet.terraform_sub3.id
  route_table_id = aws_route_table.route_nat.id
}

resource "aws_route_table_association" "terraform_associate4" {
  subnet_id      = aws_subnet.terraform_sub4.id
  route_table_id = aws_route_table.route_nat2.id
}