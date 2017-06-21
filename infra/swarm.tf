resource "aws_instance" "swarm-manager" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.micro"
    count = "${var.cluster_manager_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids      = [
      "${aws_security_group.swarm.id}",
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
      Name = "${var.vpc_key}-${var.z_region}-manager-${count.index}"
      DDBINREGION = "${var.z_region}"
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
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/node-swarm-manager-${count.index}.crt"
      destination = "/etc/flocker/node.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/node-swarm-manager-${count.index}.key"
      destination = "/etc/flocker/node.key"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/plugin.crt"
      destination = "/etc/flocker/plugin.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/plugin.key"
      destination = "/etc/flocker/plugin.key"
    }

    provisioner "file" {
      source = "agent.yml"
      destination = "/etc/flocker/agent.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo chmod 600 /etc/flocker/node.key",
        "sudo chmod 600 /etc/flocker/plugin.key",
        "sudo chmod 700 /etc/flocker",
        "sudo systemctl enable flocker-dataset-agent",
        "sudo systemctl start flocker-dataset-agent",
        "sudo systemctl enable flocker-container-agent",
        "sudo systemctl start flocker-container-agent",
        "sudo systemctl enable flocker-docker-plugin",
        "sudo systemctl start flocker-docker-plugin"
      ]
    }

    provisioner "remote-exec" {
      inline = [
        "if [ ${count.index} -eq 0 ]; then sudo docker swarm init; else sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q manager); fi"
      ]
    }
}

resource "aws_route53_record" "swarm-manager" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   count = "${var.cluster_manager_count}"
   name = "swarm-manager-${count.index}.${var.vpc_key}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${element(aws_instance.swarm-manager.*.private_ip, count.index)}"]
}

resource "aws_instance" "swarm-node" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_node_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${aws_subnet.a.id}"
    vpc_security_group_ids = [
      "${aws_security_group.swarm.id}",
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
      Name = "${var.vpc_key}-${var.z_region}-node-${count.index}"
      DDBINREGION = "${var.z_region}"
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
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/node-swarm-node-${count.index}.crt"
      destination = "/etc/flocker/node.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/node-swarm-node-${count.index}.key"
      destination = "/etc/flocker/node.key"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/plugin.crt"
      destination = "/etc/flocker/plugin.crt"
    }

    provisioner "file" {
      source = "../flocker-openssl/clusters/${var.vpc_key}.${var.z_region}.${var.z_domain}/plugin.key"
      destination = "/etc/flocker/plugin.key"
    }

    provisioner "file" {
      source = "agent.yml"
      destination = "/etc/flocker/agent.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo chmod 600 /etc/flocker/node.key",
        "sudo chmod 600 /etc/flocker/plugin.key",
        "sudo chmod 700 /etc/flocker",
        "sudo systemctl enable flocker-dataset-agent",
        "sudo systemctl start flocker-dataset-agent",
        "sudo systemctl enable flocker-container-agent",
        "sudo systemctl start flocker-container-agent",
        "sudo systemctl enable flocker-docker-plugin",
        "sudo systemctl start flocker-docker-plugin"
      ]
    }

    provisioner "remote-exec" {
      inline = [
        "sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)",
      ]
    }

    depends_on = [
      "aws_instance.swarm-manager"
    ]
}

resource "aws_route53_record" "swarm-node" {
   zone_id = "${aws_route53_zone.zdomain-vpc.zone_id}"
   count = "${var.cluster_node_count}"
   name = "swarm-node-${count.index}.${var.vpc_key}.${var.z_region}.${var.z_domain}"
   type = "A"
   ttl = "60"
   records = ["${element(aws_instance.swarm-node.*.private_ip, count.index)}"]
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.swarm-node.*.id)}"
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
      "docker -H ${element(aws_instance.swarm-manager.*.private_ip, 0)}:2375 network create --driver overlay appnet",
      "docker -H ${element(aws_instance.swarm-manager.*.private_ip, 0)}:2375 service create --name viz --publish 8080:8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet dockersamples/visualizer"
    ]
  }
}
