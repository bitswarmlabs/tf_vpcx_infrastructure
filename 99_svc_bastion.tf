/*
  Bastion Servers
*/
resource "aws_iam_role" "bastion_servers" {
  name = "bastions"
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

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion"
  roles = [
    "${aws_iam_role.bastion_servers.name}"
  ]
}

# Template for initial configuration bash script
data "template_file" "bastion_userdata" {
  template = "${file("${path.module}/scripts/centos7-bootstrap-with-puppet.tpl")}"

  vars {
    hostname = "bastion"
    domain   = "${aws_route53_zone.infrastructure.name}"
  }
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.centos7_hvm.id}"
  availability_zone = "${var.public_subnet_az}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  user_data = "${data.template_file.bastion_userdata.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion.name}"
  vpc_security_group_ids = [
    "${aws_security_group.bastion.id}"
  ]

  subnet_id = "${aws_subnet.public_primary.id}"
  associate_public_ip_address = true
  source_dest_check = false

  root_block_device {
    volume_type = "gp2"
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = false
  }

  tags {
    Name = "Bastion - ${var.public_subnet_az} (${var.vpc_name})"
    group = "${var.vpc_name}"
    profile = "bastion"
    vpc_id = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner = "${var.provisioner}"
  }

  depends_on = ["aws_iam_instance_profile.bastion"]
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

resource "aws_route53_record" "bastion-internal" {
  zone_id = "${aws_route53_zone.infrastructure.zone_id}"
  name = "bastion"
  type = "A"
  ttl = "5"
  records = [
    "${aws_instance.bastion.private_ip}"
  ]
  depends_on = ["aws_route53_zone.infrastructure"]
}

resource "aws_route53_record" "bastion-external" {
  zone_id = "${aws_route53_zone.external.zone_id}"
  name = "bastion"
  type = "A"
  ttl = "5"
  records = [
    "${aws_eip.bastion.public_ip}"
  ]
  depends_on = ["aws_route53_zone.external"]
}

resource "aws_route53_record" "bastion-cname" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name = "bastion"
  type = "CNAME"
  ttl = "5"
  records = [
    "${aws_route53_record.bastion-internal.fqdn}"
  ]
  depends_on = ["aws_route53_zone.internal"]
}
