output "vpc_id" {
  value = "${aws_vpc.infra.id}"
}

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
