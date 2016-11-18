/*
  jenkins Servers
*/
resource "aws_iam_role" "jenkins" {
  name               = "jenkins"
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

resource "aws_iam_instance_profile" "jenkins" {
  name  = "jenkins"
  roles = [ "${aws_iam_role.jenkins.name}" ]
}

# Template for initial configuration bash script
data "template_file" "jenkins_userdata" {
  template = "${file("${path.module}/templates/centos6-bootstrap-with-puppet.tpl")}"

  vars {
    hostname = "jenkins"
    domain   = "${aws_route53_zone.infrastructure.name}"
  }
}

resource "aws_instance" "jenkins" {
  depends_on             = [ "aws_iam_instance_profile.jenkins" ]
  ami                    = "${data.aws_ami.centos7_hvm.id}"
  //ami = "${lookup(var.baked_amis, "centos7.${var.aws_region}")}"
  availability_zone      = "${var.private_subnet_az}"
  instance_type          = "m4.large"
  key_name               = "${var.aws_key_name}"
  user_data              = "${data.template_file.jenkins_userdata.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.jenkins.name}"
  vpc_security_group_ids = [ "${aws_security_group.jenkins.id}" ]

  subnet_id              = "${aws_subnet.private_primary.id}"

  tags {
    Name            = "Jenkins"
    group           = "${var.vpc_name}"
    profile         = "docker"
    role            = "jenkins"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = false
  }
}

//resource "aws_eip" "jenkins" {
//  instance = "${aws_instance.jenkins.id}"
//  vpc = true
//}

resource "aws_route53_record" "jenkins-internal" {
  zone_id    = "${aws_route53_zone.infrastructure.zone_id}"
  name       = "jenkins"
  type       = "A"
  ttl        = "5"
  records    = [ "${aws_instance.jenkins.private_ip}" ]
  depends_on = [ "aws_route53_zone.infrastructure" ]
}

//resource "aws_route53_record" "jenkins-external" {
//  zone_id = "${aws_route53_zone.external.zone_id}"
//  name = "jenkins"
//  type = "A"
//  ttl = "5"
//  records = [
//    "${aws_eip.jenkins.public_ip}"
//  ]
//  depends_on = ["aws_route53_zone.external"]
//}
//
//resource "aws_route53_record" "jenkins-cname" {
//  zone_id = "${aws_route53_zone.internal.zone_id}"
//  name = "jenkins"
//  type = "CNAME"
//  ttl = "5"
//  records = [
//    "${aws_route53_record.jenkins-internal.fqdn}"
//  ]
//  depends_on = ["aws_route53_zone.internal"]
//}
