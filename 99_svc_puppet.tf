/*
  Puppetmasters
*/
resource "aws_iam_role" "puppetmasters" {
  name               = "puppetmasters"
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

resource "aws_iam_instance_profile" "puppetmaster" {
  name  = "puppetmaster"
  roles = [ "${aws_iam_role.puppetmasters.name}" ]
}


# Template for initial configuration bash script
data "template_file" "puppetserver_bootstrap_chunk_01" {
  template = "${file("${path.module}/templates/centos7-bootstrap-with-puppet.tpl")}"

  vars {
    hostname     = "puppet"
    domain       = "${aws_route53_zone.internal_vpc.name}"
  }
}

# Extra blob to drop in db backend connection infos
data "template_file" "puppetserver_bootstrap_chunk_02" {
  template = "${file("${path.module}/templates/puppetdb-facts.tpl")}"

  vars {
    puppetdb_endpoint = "${aws_db_instance.puppetdb.endpoint}"
    puppetdb_host     = "${aws_db_instance.puppetdb.address}"
    puppetdb_port     = "${aws_db_instance.puppetdb.port}"
    puppetdb_name     = "${aws_db_instance.puppetdb.name}"
    puppetdb_user     = "${aws_db_instance.puppetdb.username}"
    puppetdb_pass     = "${aws_db_instance.puppetdb.password}"
  }
}

# Final blob to install puppet server
data "template_file" "puppetserver_bootstrap_chunk_03" {
  template = "${file("${path.module}/templates/yum-puppetserver.tpl")}"
}

# Joined
data "template_file" "puppetserver_userdata" {
  template = "$${chunks}"

  vars {
    chunks = "${join("\n", list(data.template_file.puppetserver_bootstrap_chunk_01.rendered, data.template_file.puppetserver_bootstrap_chunk_02.rendered, data.template_file.puppetserver_bootstrap_chunk_03.rendered))}"
  }
}

resource "aws_instance" "puppet" {
  depends_on             = [ "aws_iam_instance_profile.puppetmaster" ]
  #ami                    = "${data.aws_ami.centos7_hvm.id}"
  ami                    = "${lookup(var.baked_amis, "centos7.${var.aws_region}")}"
  availability_zone      = "${var.private_subnet_az}"
  instance_type          = "t2.medium"
  key_name               = "${var.aws_key_name}"
  user_data              = "${data.template_file.puppetserver_userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.puppetmaster.name}"
  vpc_security_group_ids = [ "${aws_default_security_group.default.id}", "${aws_security_group.puppet.id}" ]
  subnet_id              = "${aws_subnet.private_primary.id}"
  //  disable_api_termination = true

  tags {
    Name            = "Puppetmaster"
    group           = "${var.vpc_name}"
    profile         = "puppet"
    role            = "puppetmaster"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_route53_record" "puppet_vpc" {
  zone_id    = "${aws_route53_zone.internal_vpc.zone_id}"
  name       = "puppet"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_instance.puppet.private_ip}" ]
  depends_on = [ "aws_route53_zone.internal_vpc" ]
}

resource "aws_route53_record" "puppet_vpc_ip_cname" {
  zone_id    = "${aws_route53_zone.internal_vpc.zone_id}"
  name       = "ip-${replace("${aws_instance.puppet.private_ip}", ".", "-")}"
  type       = "CNAME"
  ttl        = "5"
  records    = [ "ip-${replace("${aws_instance.puppet.private_ip}", ".", "-")}.${lookup(var.ec2_internal_zones, var.aws_region)}" ]
  depends_on = [ "aws_route53_zone.internal_vpc" ]
}

resource "aws_route53_record" "puppet_internal" {
  zone_id    = "${aws_route53_zone.internal.zone_id}"
  name       = "puppet"
  type       = "CNAME"
  ttl        = "5"
  records    = [ "${aws_route53_record.puppet_vpc.fqdn}" ]
  depends_on = [ "aws_route53_zone.internal" ]
}

resource "aws_route53_record" "puppet_internal_ip_cname" {
  zone_id    = "${aws_route53_zone.internal.zone_id}"
  name       = "ip-${replace("${aws_instance.puppet.private_ip}", ".", "-")}"
  type       = "CNAME"
  ttl        = "5"
  records    = [ "ip-${replace("${aws_instance.puppet.private_ip}", ".", "-")}.${lookup(var.ec2_internal_zones, var.aws_region)}" ]
  depends_on = [ "aws_route53_zone.internal" ]
}