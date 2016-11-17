resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}" ]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}" ]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name            = "NAT Gateway SG"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}


resource "aws_security_group" "bastion" {
  name        = "vpc_bastion"
  description = "Security group for public-facing Bastions"

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name            = "BastionSG"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

/*
  Puppetmasters
*/
resource "aws_security_group" "puppet" {
  name        = "vpc_puppet"
  description = "Security group for internal Puppet server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name            = "puppetmasterSG"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

/*
  Jenkins
 */
resource "aws_security_group" "jenkins" {
  name        = "vpc_jenkins"
  description = "Security group for public-facing Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name            = "jenkinsSG"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

/*
  Rancher Servers
*/
resource "aws_security_group" "rancher" {
  name        = "vpc_rancher"
  description = "Security group for internal Rancher servers"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${var.vpc_cidr_base}" ]
  }

  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name            = "rancherSG"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}