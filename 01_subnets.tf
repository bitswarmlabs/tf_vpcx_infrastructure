
/*
  Public Primary Subnet
*/
resource "aws_subnet" "public_primary" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.public_az.name_suffix))}"
  availability_zone = "${var.public_subnet_az}"

  tags              = {
    Name            = "${var.vpc_name} public subnet (primary)"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

/*
  Public Alternate Subnet
 */
resource "aws_subnet" "public_alternate" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.public_az_alt.name_suffix))}"
  availability_zone = "${var.public_subnet_az_alt}"

  tags              = {
    Name            = "${var.vpc_name} public subnet (alternate)"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}


/*
  Private Primary Subnet
*/
resource "aws_subnet" "private_primary" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.private_az.name_suffix))}"
  availability_zone = "${var.private_subnet_az}"

  tags {
    Name            = "${var.vpc_name} private subnet (primary)"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}


/*
  Private Alternate Subnet
 */
resource "aws_subnet" "private_alternate" {
  vpc_id            = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(aws_vpc.default.cidr_block, 4, lookup(var.az_numbers, data.aws_availability_zone.private_az_alt.name_suffix))}"
  availability_zone = "${var.private_subnet_az_alt}"

  tags {
    Name            = "${var.vpc_name} private subnet (alternate)"
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}
