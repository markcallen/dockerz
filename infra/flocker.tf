resource "aws_instance" "flocker-control" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.micro"
    count = "${var.cluster_control_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids = [
      "${aws_security_group.flocker.id}"
    ]

    root_block_device = {
      volume_size = 20
    }

    connection {
      user = "ubuntu"
      private_key = "${file("${var.ssh_key_filename}")}"
      agent = false
    }

    tags {
      Name = "${var.vpc_key}-${var.z_region}-control-${count.index}"
      ZREGION = "${var.z_region}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo mkdir /etc/flocker",
        "sudo chmod 777 /etc/flocker"
      ]
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/cluster.crt"
      destination = "/etc/flocker/cluster.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/control-service.crt"
      destination = "/etc/flocker/control-service.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/control-service.key"
      destination = "/etc/flocker/control-service.key"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo chmod 600 /etc/flocker/control-service.key",
        "sudo chmod 700 /etc/flocker",
        "sudo systemctl enable flocker-control",
        "sudo systemctl start flocker-control"
      ]
    }
}

resource "aws_route53_record" "flocker-control" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   name = "flocker-control.${var.vpc_key}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${aws_instance.flocker-control.0.private_ip}"]
}
