output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vcp_cidr_1" {
  value = "${cidrhost(aws_vpc.vpc.cidr_block,1)}"
}
output "vcp_cidr_sub_1" {
  value = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,1)}"
}

output "vpc_subnet_a" {
  value = "${aws_subnet.a.id}"
}
output "vpc_subnet_b" {
  value = "${aws_subnet.b.id}"
}

/*
output "vpc_subnet_d" {
  value = "${aws_subnet.d.id}"
}
*/

output "sg_swarm" {
  value = "${aws_security_group.swarm.id}"
}
output "swarm_managers" {
  value = "${concat(aws_instance.swarm-manager.*.public_dns)}"
}
output "swarm_storage" {
  value = "${concat(aws_instance.swarm-storage.*.public_dns)}"
}
output "swarm_app" {
  value = "${concat(aws_instance.swarm-app.*.public_dns)}"
}

output "swarm_managers_private" {
  value = "${concat(aws_instance.swarm-manager.*.private_ip)}"
}
output "swarm_storage_private" {
  value = "${concat(aws_instance.swarm-storage.*.private_ip)}"
}
output "swarm_app_private" {
  value = "${concat(aws_instance.swarm-app.*.private_ip)}"
}

output "elb" {
  value = "${aws_elb.swarm-manager.dns_name}"
}
