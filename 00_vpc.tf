/*
  Largest of the lot and configures both the VPC, the NAT instance, the two subnets and the relevant security groups.
*/
resource "aws_vpc" "default" {
  cidr_block           = "${cidrsubnet(var.vpc_cidr_base, 8, lookup(var.region_numbers, var.aws_region))}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name            = "${var.vpc_name}"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name            = "${var.vpc_name}"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

/*
  NAT Instance
*/
resource "aws_instance" "nat" {
  # pinned to latest AMI available:
  ami                         = "${data.aws_ami.nat_pv_ami.id}"
  #ami = "${lookup(var.baked_amis, "natgw.${var.aws_region}")}"

  availability_zone           = "${var.public_subnet_az}"
  instance_type               = "m1.small"
  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = [ "${aws_security_group.nat.id}" ]
  subnet_id                   = "${aws_subnet.public_primary.id}"
  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name            = "VPC NAT"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true
}


/*
  Public Subnet
*/
resource "aws_subnet" "public_primary" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.public_az.name_suffix))}"
  availability_zone = "${var.public_subnet_az}"

  tags              = {
    Name            = "${var.vpc_name} public subnet"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table" "public_primary" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name            = "${var.vpc_name} public routes"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table_association" "public_primary" {
  subnet_id      = "${aws_subnet.public_primary.id}"
  route_table_id = "${aws_route_table.public_primary.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private_primary" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.private_az.name_suffix))}"
  availability_zone = "${var.private_subnet_az}"

  tags {
    Name            = "${var.vpc_name} private subnet"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route_table" "private_primary" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name            = "${var.vpc_name} private subnet"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }

}

resource "aws_route_table_association" "private_primary" {
  subnet_id      = "${aws_subnet.private_primary.id}"
  route_table_id = "${aws_route_table.private_primary.id}"
}

resource "aws_vpc_dhcp_options" "internal" {
  domain_name = "${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}"
  tags {
    Name            = "${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_vpc_dhcp_options_association" "internal_dns_resolv" {
  vpc_id          = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.internal.id}"
}