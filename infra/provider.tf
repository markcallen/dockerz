provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.z_network}-${var.z_region}-ig"
    Z_REGION = "${var.z_region}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_network_acl" "network" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.a.id}",
    "${aws_subnet.b.id}"
  ]

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
  vpc_id = "${aws_vpc.vpc.id}"

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

resource "aws_route_table_association" "a" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.a.id}"
}

resource "aws_route_table_association" "b" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.b.id}"
}

/* TODO: need to get this dynamically based upon the region */
resource "aws_route_table_association" "d" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.d.id}"
}

resource "aws_subnet" "a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,1)}"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.z_network}-${var.z_region}-a"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_subnet" "b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,2)}"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.z_network}-${var.z_region}-b"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_subnet" "d" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,3)}"
  availability_zone = "${var.aws_region}d"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.z_network}-${var.z_region}-d"
    Z_REGION = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_vpc" "vpc" {
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

