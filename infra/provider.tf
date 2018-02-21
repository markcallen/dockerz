provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "infra" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    Name = "${var.z_network}-${var.z_region}-vpc"
    VPC = "${var.vpc_key}"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    Terraform = "Terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.infra.id}"

  tags {
    Name = "${var.z_network}-${var.z_region}-ig"
    Z_REGION = "${var.z_region}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_network_acl" "infra" {
  vpc_id = "${aws_vpc.infra.id}"
  subnet_ids = [ "${aws_subnet.infra.*.id}" ]

  ingress {
    from_port = 0
    to_port = 0
    rule_no = 100
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port = 0
    to_port = 0
    rule_no = 100
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.z_network}-${var.z_region}-network"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.infra.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.z_network}-${var.z_region}-route"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}


data "aws_availability_zones" "available" {}

resource "aws_subnet" "infra" {
  vpc_id = "${aws_vpc.infra.id}"
  count = "${length(data.aws_availability_zones.available.names)}"
  cidr_block = "${cidrsubnet(aws_vpc.infra.cidr_block,8,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.z_network}-${var.z_region}-${element(data.aws_availability_zones.available.names, count.index)}"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_route_table_association" "infra" {
  route_table_id = "${aws_route_table.main.id}"
  count = "${length(data.aws_availability_zones.available.names)}" # Using data.aws_availability_zones.available.names as aws_subnet.infra.*.id does not work
  subnet_id = "${element(aws_subnet.infra.*.id, count.index)}"
}

