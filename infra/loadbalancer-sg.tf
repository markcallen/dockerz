resource "aws_security_group" "loadbalancer" {
  name        = "${var.z_network}-${var.z_region}-sg-loadbalaner"
  description = "Security group for loadbalaner"
  vpc_id      = "${aws_vpc.infra.id}"


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
    Name = "${var.z_network}-${var.z_region}-sg-loadbalancer"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
