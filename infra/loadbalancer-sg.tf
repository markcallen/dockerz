resource "aws_security_group" "loadbalancer" {
  name        = "${var.vpc_key}-${var.z_region}-sg-loadbalaner"
  description = "Security group for loadbalaner"
  vpc_id      = "${aws_vpc.vpc.id}"


  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  ingress {
      from_port   = 443
      to_port     = 443
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
    Name = "${var.vpc_key}-${var.z_region}-sg-loadbalancer"
    DDBINREGION = "${var.z_region}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
