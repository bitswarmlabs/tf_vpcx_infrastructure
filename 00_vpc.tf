provider "aws" {
  region = "${var.aws_region}"
}

/*
  Managing the VPC
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
  NAT Gateway Instance
*/
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id =  "${aws_subnet.public_primary.id}"
  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_route53_record" "natgw_vpc" {
  zone_id    = "${aws_route53_zone.internal_vpc.zone_id}"
  name       = "gw"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_nat_gateway.gw.private_ip}" ]
  depends_on = [ "aws_route53_zone.internal_vpc" ]
}

resource "aws_route53_record" "natgw_vpc_ip_cname" {
  zone_id    = "${aws_route53_zone.internal_vpc.zone_id}"
  name       = "ip-${replace("${aws_nat_gateway.gw.private_ip}", ".", "-")}"
  type       = "CNAME"
  ttl        = "5"
  records    = [ "ip-${replace("${aws_nat_gateway.gw.private_ip}", ".", "-")}.${lookup(var.ec2_internal_zones, var.aws_region)}" ]
  depends_on = [ "aws_route53_zone.internal_vpc" ]
}

resource "aws_route53_record" "natgw_external" {
  zone_id    = "${aws_route53_zone.external.zone_id}"
  name       = "${var.vpc_code}-gw"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_nat_gateway.gw.public_ip}" ]
  depends_on = [ "aws_route53_zone.external" ]
}



//Formerly:
//
//resource "aws_instance" "nat" {
//  # pinned to latest AMI available:
//  ami                         = "${data.aws_ami.nat_pv_ami.id}"
//  #ami = "${lookup(var.baked_amis, "natgw.${var.aws_region}")}"
//
//  availability_zone           = "${var.public_subnet_az}"
//  instance_type               = "m1.small"
//  key_name                    = "${var.aws_key_name}"
//  vpc_security_group_ids      = [ "${aws_security_group.nat.id}" ]
//  subnet_id                   = "${aws_subnet.public_primary.id}"
//  associate_public_ip_address = true
//  source_dest_check           = false
//
//  tags {
//    Name            = "VPC NAT"
//    vpc_id          = "${aws_vpc.default.id}"
//    vpc_environment = "${var.vpc_environment}"
//    provisioner     = "${var.provisioner}"
//  }
//}
//
//resource "aws_eip" "nat" {
//  instance = "${aws_instance.nat.id}"
//  vpc      = true
//}

/*
  DHCP Option Set
 */
resource "aws_vpc_dhcp_options" "internal_region" {
  domain_name = "${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name            = "${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_vpc_dhcp_options" "internal" {
  domain_name = "infra.${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")} ${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}"
  domain_name_servers = ["AmazonProvidedDNS"]
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