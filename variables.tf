variable "provisioner" {
  description = "Provisioner e.g. terraform, ci. Will be used for tags and consequently for IAM security policies"
  default     = "terraform"
}

//variable "aws_access_key" {}
//variable "aws_secret_key" {}
//variable "aws_key_path" {}

variable "aws_key_name" {
  description = "EC2 keypair name"
}

variable "aws_region" {
  description = "Target AWS region"
}

variable "vpc_cidr_base" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Root name of VPC, will also be used for child resources"
}

variable "vpc_code" {
  description = "Abbreviated name code prefix for use in constructing Route53 subdomains for this specific VPC"
}

variable "vpc_environment" {
  description = "VPC operational environment, e.g. development, production.  Used as tag."
}

variable "vpc_environment_code" {
  description = "Abbreviated environment code prefix for use in constructing Route53 subdomains"
}

variable "private_subnet_az" {
  description = "Private subnet (primary) availability zone"
}

variable "private_subnet_az_alt" {
  description = "Private subnet (alternate) availability zone"
}

variable "public_subnet_az" {
  description = "Public subnet (primary) availability zone"
}

variable "public_subnet_az_alt" {
  description = "Public subnet (alternate) availability zone"
}

data "aws_availability_zones" "available" { }

data "aws_availability_zone" "private_az" {
  name = "${var.private_subnet_az}"
}

data "aws_availability_zone" "private_az_alt" {
  name = "${var.private_subnet_az_alt}"
}

data "aws_availability_zone" "public_az" {
  name = "${var.public_subnet_az}"
}

data "aws_availability_zone" "public_az_alt" {
  name = "${var.public_subnet_az_alt}"
}

# Finding the latest marketplace ami for CentOS 6 (x86_64) - with Updates (PV)
data "aws_ami" "centos6_pv" {
  most_recent = true

  filter {
    name   = "product-code"
    values = [ "aacglxeowvn5hy8sznltowyqe" ]
  }

  owners      = [ "679593333241" ]
}

# Finding the latest marketplace ami for CentOS 7 (x86_64) - with Updates HVM"
# https://aws.amazon.com/marketplace/pp/B00O7WM7QW
data "aws_ami" "centos7_hvm" {
  most_recent = true

  filter {
    name   = "product-code"
    values = [ "aw0evgkw8e5c1q413zgy5pjce" ]
  }

  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }

  owners      = [ "679593333241" ]
}

# Finding the latest Ubuntu Trusty MAI
data "aws_ami" "ubuntu_trusty_hvm" {
  most_recent = true
  filter {
    name   = "name"
    values = [ "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*" ]
  }
  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }
  owners      = [ "099720109477" ]
}

# Finding the latest Amazon NAT gateway AMI
data "aws_ami" "nat_hvm" {
  most_recent = true
  filter {
    name   = "name"
    values = [ "amzn-ami-vpc-nat*" ]
  }
  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }
}

# Finding the latest Amazon NAT gateway AMI (previous generation PV virtualization)
data "aws_ami" "nat_pv_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = [ "amzn-ami-vpc-nat-pv*" ]
  }
}

# Better to use the Data providers as demonstrated above..
variable "baked_amis" {
  description = "Pre-baked AMIs by [type].[g]"

  default {
    # AWS baked PV NAT gateways amzn-ami-vpc-nat-pv-2015.03.0.x86_64-ebs
    natgw.us-east-1   = "ami-c02b04a8"
    natgw.us-west-1   = "ami-67a54423"

    # centos7 marketplace amis: https://aws.amazon.com/marketplace/pp/B00O7WM7QW
    centos7.us-east-1 = "ami-6d1c2007"
    centos7.us-west-1 = "ami-af4333cf"
  }
}

variable "external_root_domain" {
  description = "Domain name to be used for internet facing service registration"
  default     = "example.com"
}

variable "external_zones" {
  description = "Map of external Route53 zone name prefixes by environment and region"
  default {
    development.us-east-1 = "dvl-us-east-1"
    development.us-west-1 = "dvl-us-west-1"
    staging.us-east-1     = "stg-us-east-1"
    staging.us-west-1     = "stg-us-west-1"
    production.us-east-1  = "us-east-1"
    production.us-west-1  = "us-west-1"
  }
}

variable "internal_zones" {
  description = "Map of internal Route53 zone names by environment and region"
  default {
    development.us-east-1 = "dvl-us-east-1.bitswarm.internal"
    development.us-west-1 = "dvl-us-west-1.bitswarm.internal"
    staging.us-east-1     = "stg-us-east-1.bitswarm.internal"
    staging.us-west-1     = "stg-us-west-1.bitswarm.internal"
    production.us-east-1  = "us-east-1.bitswarm.internal"
    production.us-west-1  = "us-west-1.bitswarm.internal"
  }
}

variable "region_numbers" {
  default {
    us-east-1 = 1
    us-west-1 = 2
    us-west-2 = 3
    eu-west-1 = 4
  }
}

variable "az_numbers" {
  default {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
    h = 8
    i = 9
    j = 10
    k = 11
    l = 12
    m = 13
    n = 14
  }
}

variable "puppetdb_name" {
  default     = "puppetdb"
  description = "puppetdb database name"
}

variable "puppetdb_user" {
  default     = "puppetdb"
  description = "puppetdb database user"
}

variable "puppetdb_pass" {
  description = "puppetdb password, provide through your ENV variables"
}

variable "puppetdb_storage_size" {
  default     = "10"
  description = "puppetdb storage size in GB"
}

variable "rancherdb_name" {
  default     = "rancher"
  description = "rancher database name"
}

variable "rancherdb_user" {
  default     = "rancher"
  description = "rancher database user"
}

variable "rancherdb_pass" {
  description = "rancher database password, provide through your ENV variables"
}

variable "rancherdb_storage_size" {
  default     = "1"
  description = "rancher database storage size in GB"
}
