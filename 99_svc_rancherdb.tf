resource "aws_security_group" "rancherdb_rds" {
  name        = "rancherdb_rds_sg"
  description = "Allow inbound traffic from Rancher server only"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = [ "${aws_subnet.private_primary.cidr_block}", "${aws_subnet.private_alternate.cidr_block}" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "${aws_vpc.default.cidr_block}" ]
  }

  tags {
    Name            = "RancherDB RDS SG"
    profile         = "rancher"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_db_instance" "rancherdb" {
  identifier             = "rancherdb-rds"
  allocated_storage      = "${var.rancherdb_storage_size}"
  engine                 = "mysql"
  engine_version         = "5.6.22"
  instance_class         = "db.t2.micro"
  name                   = "${var.rancherdb_name}"
  username               = "${var.rancherdb_user}"
  password               = "${var.rancherdb_pass}"
  vpc_security_group_ids = [ "${aws_security_group.rancherdb_rds.id}" ]
  db_subnet_group_name   = "${aws_db_subnet_group.rancherdb.name}"

  tags {
    Name            = "RancherDB MySQL"
    profile         = "rancher"
    group           = "${var.vpc_name}"
    vpc_id          = "${aws_vpc.default.id}"
    vpc_environment = "${var.vpc_environment}"
    provisioner     = "${var.provisioner}"
  }
}

resource "aws_db_subnet_group" "rancherdb" {
  name        = "rancherdb_subnet_group"
  description = "Our group of subnets for rancherDB"
  subnet_ids  = ["${aws_subnet.private_primary.id}", "${aws_subnet.private_alternate.id}"]
}