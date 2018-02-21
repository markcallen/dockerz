
resource "aws_elb" "swarm-manager" {
  name = "${var.z_network}-${var.z_region}-elb"

  security_groups      = [
    "${aws_security_group.loadbalancer.id}"
  ]

  subnets = [ "${aws_subnet.infra.*.id}" ]


/*
  access_logs {
    bucket = "foo"
    bucket_prefix = "bar"
    interval = 60
  }
*/

  listener {
    instance_port = 8000
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 8000
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.certificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8001/apis"
    interval = 30
  }

  instances = ["${aws_instance.swarm-manager.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.z_network}-${var.z_region}-elb"
    Z_REGION = "${var.z_region}"
    Z_NETWORK = "${var.z_network}"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }

  depends_on = [
    "aws_instance.swarm-manager"
  ]
}

resource "aws_route53_record" "swarm-manager-elb" {
  zone_id = "${var.z_zone_id}"
  name = "swarm-${var.z_network}-${var.z_region}"
  type = "CNAME"
  ttl = "5"
  weighted_routing_policy {
    weight = 10
  }
  set_identifier = "${var.z_network}-${var.z_region}"
  records = ["${aws_elb.swarm-manager.dns_name}"]
}

resource "aws_route53_record" "wildcard-swarm-manager-elb" {
  zone_id = "${var.z_zone_id}"
  name = "*.swarm-${var.z_network}-${var.z_region}"
  type = "CNAME"
  ttl = "5"
  weighted_routing_policy {
    weight = 10
  }
  set_identifier = "${var.z_network}-${var.z_region}"
  records = ["${aws_elb.swarm-manager.dns_name}"]
}
