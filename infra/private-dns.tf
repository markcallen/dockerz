
resource "aws_route53_zone" "zdomain-vpc" {
  name = "${var.z_network}.${var.z_region}.${var.z_domain}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.z_network}.${var.z_region}"
  }
}

resource "aws_route53_record" "zdomain-vpc-ns" {
    zone_id = "${var.z_zone_id}"  
    name = "${var.z_network}.${var.z_region}.${var.z_domain}"
    type = "NS"
    ttl = "172800"
    records = [
        "${aws_route53_zone.zdomain-vpc.name_servers.0}",
        "${aws_route53_zone.zdomain-vpc.name_servers.1}",
        "${aws_route53_zone.zdomain-vpc.name_servers.2}",
        "${aws_route53_zone.zdomain-vpc.name_servers.3}"
    ]
}
