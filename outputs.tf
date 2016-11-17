
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