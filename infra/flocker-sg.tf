resource "aws_security_group" "flocker" {
  name        = "${var.vpc_key}-${var.z_region}-sg-flocker"
  description = "Security group for flocker cluster instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 4523
      to_port     = 4524
      protocol    = "tcp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  tags {
    Name = "${var.vpc_key}-sg-flocker"
    ZREGION = "${var.z_region}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
