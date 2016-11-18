
resource "aws_security_group" "puppetdb_rds" {
  name        = "puppetdb_rds_sg"
  description = "Allow inbound traffic from Puppet server only"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}",  "${aws_subnet.private_alternate.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "${aws_vpc.default.cidr_block}" ]
  }

  tags {
    Name            = "PuppetDB RDS SG"
    profile         = "puppet"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_db_instance" "puppetdb" {
  identifier             = "puppetdb-rds"
  allocated_storage      = "${var.puppetdb_storage_size}"
  engine                 = "postgres"
  engine_version         = "9.4.1"
  instance_class         = "db.t2.micro"
  name                   = "${var.puppetdb_name}"
  username               = "${var.puppetdb_user}"
  password               = "${var.puppetdb_pass}"
  vpc_security_group_ids = ["${aws_security_group.puppetdb_rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.puppetdb.id}"
}

resource "aws_db_subnet_group" "puppetdb" {
  name        = "puppetdb_subnet_group"
  description = "Our group of subnets for PuppetDB"
  subnet_ids  = ["${aws_subnet.private_primary.id}", "${aws_subnet.private_alternate.id}"]
}