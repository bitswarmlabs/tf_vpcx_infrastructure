/*
  Puppetmasters
*/
resource "aws_iam_role" "puppetmasters" {
  name = "puppetmasters"
  path = "/infrastructure/"
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

resource "aws_iam_instance_profile" "puppetmaster" {
  name = "puppetmaster"
  roles = [
    "${aws_iam_role.puppetmasters.name}"
  ]
}

# Template for initial configuration bash script
data "template_file" "puppet_userdata" {
  template = "${file("${path.module}/scripts/ec2-hostname.tpl")}"

  vars {
    hostname = "puppet"
    domain   = "${aws_route53_zone.infrastructure.name}"
  }
}

resource "aws_instance" "puppet" {
  ami = "${data.aws_ami.centos7_hvm.id}"
  #ami = "${lookup(var.baked_amis, "puppet.${var.aws_region}")}"
  availability_zone = "${var.private_subnet_az}"
  instance_type = "t2.medium"
  key_name = "${var.aws_key_name}"
  user_data = "${data.template_file.puppet_userdata.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.puppetmaster.name}"
  vpc_security_group_ids = ["${aws_security_group.puppet.id}"]
  subnet_id = "${aws_subnet.private_primary.id}"

  tags = {
    Name = "Puppetmaster"
    group = "${var.vpc_name}"
    role = "puppetmaster"
    vpc_id = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner = "${var.provisioner}"
  }

  depends_on = ["aws_iam_instance_profile.puppetmaster"]
}

resource "aws_route53_record" "puppet-internal" {
  zone_id = "${aws_route53_zone.infrastructure.zone_id}"
  name = "puppet"
  type = "A"
  ttl = "5"
  records = [
    "${aws_instance.puppet.private_ip}"
  ]
  depends_on = ["aws_route53_zone.infrastructure"]
}

//resource "aws_route53_record" "puppet-external" {
//  zone_id = "${aws_route53_zone.external.zone_id}"
//  name = "puppet"
//  type = "A"
//  ttl = "5"
//  records = [
//    "${aws_eip.puppet.public_ip}"
//  ]
//  depends_on = ["aws_route53_zone.external"]
//}
//
//resource "aws_route53_record" "puppet-cname" {
//  zone_id = "${aws_route53_zone.internal.zone_id}"
//  name = "puppet"
//  type = "CNAME"
//  ttl = "5"
//  records = [
//    "${aws_route53_record.puppet-internal.fqdn}"
//  ]
//  depends_on = ["aws_route53_zone.internal"]
//}
