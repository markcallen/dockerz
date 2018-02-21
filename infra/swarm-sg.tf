resource "aws_security_group" "swarm" {
  name        = "${var.z_network}-${var.z_region}-sg-swarm"
  description = "Security group for swarm cluster instances"
  vpc_id      = "${aws_vpc.infra.id}"

  ingress {
      from_port   = 2375
      to_port     = 2377
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      self        = true
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      self        = true
  }

  ingress {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 9001
      to_port     = 9006
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 24007
      to_port     = 24008
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 49152
      to_port     = 49160
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 38465
      to_port     = 38467
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 111
      to_port     = 111
      protocol    = "tcp"
      self        = true
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  ingress {
      from_port   = 8000
      to_port     = 8001
      protocol    = "tcp"
      security_groups      = [
        "${aws_security_group.loadbalancer.id}"
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
    Name = "${var.z_network}-${var.z_region}-sg-swarm"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
