//resource "aws_security_group" "default" {
//  name        = "default"
//  description = "Default VPC security group"
//  vpc_id      = "${aws_vpc.default.id}"
//
//  ingress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    self =true
//  }
//
//  egress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  tags {
//    Name            = "Default"
//    group           = "${var.vpc_name}"
//    vpc_id          = "${aws_vpc.default.id}"
//    vpc_environment = "${var.vpc_environment}"
//    provisioner     = "${var.provisioner}"
//  }
//}

resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"
  vpc_id      = "${aws_vpc.default.id}"

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
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = -1
    to_port     = -1
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
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  egress {
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
  see https://docs.puppet.com/pe/latest/sys_req_sysconfig.html#for-monolithic-installs
*/
resource "aws_security_group" "puppet" {
  name        = "vpc_puppet"
  description = "Security group for internal Puppet server"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 4443
    to_port     = 4443
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 61613
    to_port     = 61613
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 61616
    to_port     = 61616
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 8140
    to_port     = 8143
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 8150
    to_port     = 8151
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  ingress {
    from_port   = 4432
    to_port     = 4433
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.vpc_cidr_base}" ]
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
