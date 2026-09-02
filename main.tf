resource "aws_vpc" "name" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-vpc"
    }
  )

}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.name.id
  
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-ig"
    }
  )

}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.name.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public_route"
    }
  )
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.name.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private_route"
    }
  )
}

resource "aws_route_table" "database_route" {
  vpc_id = aws_vpc.name.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database_route"
    }
  )
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-eip"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)
  cidr_block = var.public_subnet[count.index]
  vpc_id = aws_vpc.name.id
  availability_zone = local.az[count.index]
  map_public_ip_on_launch = "true"

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public_subnet"
    }
  )

}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)
  vpc_id = aws_vpc.name.id
  availability_zone = local.az[count.index]
  cidr_block = var.private_subnet[count.index]

   tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private_subnet"
    }
  )
}

resource "aws_subnet" "database_subnet" {
  count = length(var.database_subnet)
  vpc_id = aws_vpc.name.id
  availability_zone = local.az[count.index]
  cidr_block = var.database_subnet[count.index]
  
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database_subnet"
    }
  )

}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public_subnet[0].id 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-nat_gateway"
    }
  )

}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
  route_table_id = aws_route_table.database_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.public_subnet)
  subnet_id = aws_subnet.public_subnet[count.index]
  route_table_id = aws_route_table.public_route.id

}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.private_subnet)
  subnet_id = aws_subnet.private_subnet[count.index]
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "database_route_table_association" {
  count = length(var.private_subnet)
  subnet_id = aws_subnet.private_subnet[count.index]
  route_table_id = aws_route_table.database_route.id
}