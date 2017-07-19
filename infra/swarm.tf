resource "aws_instance" "swarm-manager" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_manager_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids      = [
      "${aws_security_group.swarm.id}"
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
      Name = "${var.z_network}-${var.z_region}-manager-${count.index}"
      Z_REGION = "${var.z_region}"
      Z_NETWORK = "${var.z_network}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "if [ ${count.index} -eq 0 ]; then sudo docker swarm init; else sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q manager); fi",
        "docker -H ${aws_instance.swarm-manager.0.private_ip} node update --label-add nodetype=manager $HOSTNAME"
      ]
    }
}

resource "aws_ebs_volume" "storage-manager" {
  count = "${var.cluster_manager_count}"
  availability_zone = "${var.aws_region}a"
  type = "gp2"
  size = "50"
}

resource "aws_volume_attachment" "storage-manager" {
  count = "${var.cluster_manager_count}"
  device_name = "/dev/xvdd"
  volume_id = "${element(aws_ebs_volume.storage-manager.*.id, count.index)}"
  instance_id = "${element(aws_instance.swarm-manager.*.id, count.index)}"
}

resource "aws_route53_record" "swarm-manager" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   count = "${var.cluster_manager_count}"
   name = "swarm-manager-${count.index}.${var.z_network}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${element(aws_instance.swarm-manager.*.private_ip, count.index)}"]
}

resource "aws_instance" "swarm-app" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_node_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids = [
      "${aws_security_group.swarm.id}"
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
      Name = "${var.z_network}-${var.z_region}-app-${count.index}"
      Z_REGION = "${var.z_region}"
      Z_NETWORK = "${var.z_network}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)",
        "docker -H ${aws_instance.swarm-manager.0.private_ip} node update --label-add nodetype=app $HOSTNAME"
      ]
    }

    depends_on = [
      "aws_instance.swarm-manager"
    ]
}

resource "aws_route53_record" "swarm-app" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   count = "${var.cluster_node_count}"
   name = "swarm-app-${count.index}.${var.z_network}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${element(aws_instance.swarm-app.*.private_ip, count.index)}"]
}

resource "aws_instance" "swarm-storage" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_node_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids = [
      "${aws_security_group.swarm.id}"
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
      Name = "${var.z_network}-${var.z_region}-storage-${count.index}"
      Z_REGION = "${var.z_region}"
      Z_NETWORK = "${var.z_network}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)",
        "docker -H ${aws_instance.swarm-manager.0.private_ip} node update --label-add nodetype=storage $HOSTNAME"
      ]
    }

    depends_on = [
      "aws_instance.swarm-manager"
    ]
}

resource "aws_ebs_volume" "swarm-storage" {
  count = "${var.cluster_node_count}"
  availability_zone = "${var.aws_region}a"
  type = "gp2"
  size = "50"
}

resource "aws_volume_attachment" "swarm-storage" {
  count = "${var.cluster_node_count}"
  device_name = "/dev/xvdd"
  volume_id = "${element(aws_ebs_volume.swarm-storage.*.id, count.index)}"
  instance_id = "${element(aws_instance.swarm-storage.*.id, count.index)}"
}

resource "aws_route53_record" "swarm-storage" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   count = "${var.cluster_node_count}"
   name = "swarm-storage-${count.index}.${var.z_network}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${element(aws_instance.swarm-storage.*.private_ip, count.index)}"]
}

resource "null_resource" "cluster-manager" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.swarm-manager.*.id)}"
  }

  connection {
    host = "${element(aws_instance.swarm-manager.*.public_ip, 0)}"
    user = "ubuntu"
    private_key = "${file("${var.ssh_key_filename}")}"
    agent = false
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "docker -H ${element(aws_instance.swarm-manager.*.private_ip, 0)}:2375 network create --driver overlay appnet"
    ]
  }
}
