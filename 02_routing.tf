/*
  Public subnet routing
*/
resource "aws_route_table" "public_primary" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name            = "${var.vpc_name} public (primary) routes"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table" "public_alternate" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name            = "${var.vpc_name} public (alternate) routes"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table_association" "public_primary" {
  subnet_id      = "${aws_subnet.public_primary.id}"
  route_table_id = "${aws_route_table.public_primary.id}"
}

resource "aws_route_table_association" "public_alternate" {
  subnet_id      = "${aws_subnet.public_alternate.id}"
  route_table_id = "${aws_route_table.public_alternate.id}"
}


/*
  Private subnet routing
*/
resource "aws_route_table" "private_primary" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name            = "${var.vpc_name} private (primary) routes"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table_association" "private_primary" {
  subnet_id      = "${aws_subnet.private_primary.id}"
  route_table_id = "${aws_route_table.private_primary.id}"
}


resource "aws_route_table" "private_alternate" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name            = "${var.vpc_name} private (alternate) routes"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table_association" "private_alternate" {
  subnet_id      = "${aws_subnet.private_alternate.id}"
  route_table_id = "${aws_route_table.private_alternate.id}"
}

