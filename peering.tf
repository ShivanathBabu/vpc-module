resource "aws_vpc_peering_connection" "foo" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id = data.aws_vpc.default.id
  vpc_id = aws_vpc.name.id
  auto_accept = "true"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "public_subnet_default_vpc" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.public_route.id
  destination_cidr_block = data.aws_subnets.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[count.index].id
}

resource "aws_route" "private_subnet_default_vpc" {
  count = var.is_peering_required ? 1:0
  route_table_id = aws_route_table.private_route.id
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[count.index].id 
}

resource "aws_route" "database_subnet_default_vpc" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.public_route.id
  destination_cidr_block = data.aws_subnets.default.cidr_block  
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[count.index].id

}

resource "aws_route" "default_vpc" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = data.aws_route_table.name.id
  destination_cidr_block = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[count.index].id

}
