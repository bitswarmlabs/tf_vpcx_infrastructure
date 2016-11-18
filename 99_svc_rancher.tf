/*
  Rancher Servers
*/
resource "aws_iam_role" "rancher" {
  name               = "rancher"
  path               = "/${var.vpc_code}/"
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
data "template_file" "rancher_bootstrap_chunk_01" {
  template = "${file("${path.module}/templates/ubuntu-bootstrap-with-puppet.tpl")}"

  vars {
    hostname     = "rancher"
    domain       = "${aws_route53_zone.internal_vpc.name}"
  }
}

# Extra blob to install puppet server
data "template_file" "rancher_bootstrap_chunk_02" {
  template = "${file("${path.module}/templates/rancherdb-facts.tpl")}"

  vars {
    rancherdb_endpoint = "${aws_db_instance.rancherdb.endpoint}"
    rancherdb_host     = "${aws_db_instance.rancherdb.address}"
    rancherdb_port     = "${aws_db_instance.rancherdb.port}"
    rancherdb_name     = "${aws_db_instance.rancherdb.name}"
    rancherdb_user     = "${aws_db_instance.rancherdb.username}"
    rancherdb_pass     = "${aws_db_instance.rancherdb.password}"
  }
}

# Joined
data "template_file" "rancher_userdata" {
  template = "$${chunks}"

  vars {
    chunks = "${join("\n", list(data.template_file.rancher_bootstrap_chunk_01.rendered, data.template_file.rancher_bootstrap_chunk_02.rendered))}"
  }
}

resource "aws_instance" "rancher" {
  depends_on             = [ "aws_iam_instance_profile.rancher" ]
  ami                    = "${data.aws_ami.ubuntu_trusty_hvm.id}"
  //ami = "${lookup(var.baked_amis, "centos7.${var.aws_region}")}"
  availability_zone      = "${var.private_subnet_az}"
  instance_type          = "m4.large"
  key_name               = "${var.aws_key_name}"
  user_data              = "${data.template_file.rancher_userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.rancher.name}"
  vpc_security_group_ids = [ "${aws_security_group.rancher.id}" ]

  subnet_id              = "${aws_subnet.private_primary.id}"

  tags {
    Name            = "Rancher"
    group           = "${var.vpc_name}"
    profile         = "rancher"
    role            = "rancherserver"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route53_record" "rancher_vpc" {
  zone_id    = "${aws_route53_zone.internal_vpc.zone_id}"
  name       = "rancher"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_instance.rancher.private_ip}" ]
  depends_on = [ "aws_route53_zone.internal_vpc" ]
}

resource "aws_route53_record" "rancher_internal" {
  zone_id    = "${aws_route53_zone.internal.zone_id}"
  name       = "rancher"
  type       = "CNAME"
  ttl        = "5"
  records    = [ "${aws_route53_record.rancher_vpc.fqdn}" ]
  depends_on = [ "aws_route53_zone.internal" ]
}