/*
  Rancher Servers
*/
resource "aws_iam_role" "rancher" {
  name               = "rancher"
  path               = "/infrastructure/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "rancher" {
  name  = "rancher"
  roles = [ "${aws_iam_role.rancher.name}" ]
}

# Template for initial configuration bash script
data "template_file" "rancher_userdata" {
  template = "${file("${path.module}/scripts/ubuntu-bootstrap-with-puppet.tpl")}"

  vars {
    hostname = "rancher"
    domain   = "${aws_route53_zone.infrastructure.name}"
  }
}

resource "aws_instance" "rancher" {
  ami                    = "${data.aws_ami.ubuntu_trusty_hvm.id}"
  //ami = "${lookup(var.baked_amis, "centos7.${var.aws_region}")}"
  availability_zone      = "${var.private_subnet_az}"
  instance_type          = "m4.large"
  key_name               = "${var.aws_key_name}"
  user_data              = "${data.template_file.rancher_userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.rancher.name}"
  vpc_security_group_ids = [ "${aws_security_group.rancher.id}" ]

  subnet_id              = "${aws_subnet.private_primary.id}"

  tags                   = {
    Name            = "Rancher"
    group           = "${var.vpc_name}"
    profile         = "docker"
    role            = "rancher"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }

  depends_on             = [ "aws_iam_instance_profile.rancher" ]
}

//resource "aws_eip" "rancher" {
//  instance = "${aws_instance.rancher.id}"
//  vpc = true
//}

resource "aws_route53_record" "rancher-internal" {
  zone_id    = "${aws_route53_zone.infrastructure.zone_id}"
  name       = "rancher"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_instance.rancher.private_ip}" ]
  depends_on = [ "aws_route53_zone.infrastructure" ]
}

//resource "aws_route53_record" "rancher-external" {
//  zone_id = "${aws_route53_zone.external.zone_id}"
//  name = "rancher"
//  type = "A"
//  ttl = "5"
//  records = [
//    "${aws_eip.rancher.public_ip}"
//  ]
//  depends_on = ["aws_route53_zone.external"]
//}
//
//resource "aws_route53_record" "rancher-cname" {
//  zone_id = "${aws_route53_zone.internal.zone_id}"
//  name = "rancher"
//  type = "CNAME"
//  ttl = "5"
//  records = [
//    "${aws_route53_record.rancher-internal.fqdn}"
//  ]
//  depends_on = ["aws_route53_zone.internal"]
//}
