
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.default.cidr_block}"
}

output "bastion_external_fqdn" {
  value = "${aws_route53_record.bastion-external.fqdn}"
}

output "bastion_internal_fqdn" {
  value = "${aws_route53_record.bastion-internal.fqdn}"
}

output "puppet_internal_fqdn" {
  value = "${aws_route53_record.puppet-internal.fqdn}"
}

output "rancher_internal_fqdn" {
  value = "${aws_route53_record.rancher-internal.fqdn}"
}

output "jenkins_internal_fqdn" {
  value = "${aws_route53_record.jenkins-internal.fqdn}"
}

output "bastion_userdata" {
  value = "${data.template_file.bastion_userdata.rendered}"
}

output "puppet_userdata" {
  value = "${data.template_file.puppetserver_userdata.rendered}"
}

output "jenkins_userdata" {
  value = "${data.template_file.jenkins_userdata.rendered}"
}

output "rancher_userdata" {
  value = "${data.template_file.rancher_userdata.rendered}"
}

output "puppetdb_host" {
  value = "${aws_db_instance.puppetdb.endpoint}"
}

output "puppetdb_name" {
  value = "${var.puppetdb_name}"
}

output "puppetdb_user" {
  value = "${var.puppetdb_user}"
}

output "puppetdb_pass" {
  value = "${var.puppetdb_pass}"
  sensitive = true
}


output "rancherdb_host" {
  value = "${aws_db_instance.rancherdb.endpoint}"
}

output "rancherdb_name" {
  value = "${var.rancherdb_name}"
}

output "rancherdb_user" {
  value = "${var.rancherdb_user}"
}

output "rancherdb_pass" {
  value = "${var.rancherdb_pass}"
  sensitive = true
}
