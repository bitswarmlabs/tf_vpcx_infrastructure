resource "aws_route53_zone" "root" {
  name          = "${var.external_root_domain}."

  tags {
    provisioner = "${var.provisioner}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_zone" "external" {
  name          = "${lookup(var.external_zones, "${var.vpc_environment}.${var.aws_region}")}.${var.external_root_domain}."

  tags {
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route53_record" "external-ns" {
  name    = "${lookup(var.external_zones, "${var.vpc_environment}.${var.aws_region}")}"
  zone_id = "${aws_route53_zone.root.zone_id}"
  type    = "NS"
  ttl     = "30"
  records = [
    "${aws_route53_zone.external.name_servers.0}",
    "${aws_route53_zone.external.name_servers.1}",
    "${aws_route53_zone.external.name_servers.2}",
    "${aws_route53_zone.external.name_servers.3}" ]
}

resource "aws_route53_zone" "internal" {
  name          = "${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}."
  force_destroy = "false"
  tags {
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route53_zone" "infrastructure" {
  name          = "infra.${lookup(var.internal_zones, "${var.vpc_environment}.${var.aws_region}")}."
  vpc_id        = "${aws_vpc.default.id}"
  vpc_region    = "${var.aws_region}"
  force_destroy = "false"
  tags {
    group           = "${var.vpc_name}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route53_record" "infrastructure-ns" {
  name    = "infra"
  zone_id = "${aws_route53_zone.internal.zone_id}"
  type    = "NS"
  ttl     = "30"
  records = [
    "${aws_route53_zone.infrastructure.name_servers.0}",
    "${aws_route53_zone.infrastructure.name_servers.1}",
    "${aws_route53_zone.infrastructure.name_servers.2}",
    "${aws_route53_zone.infrastructure.name_servers.3}" ]
}
