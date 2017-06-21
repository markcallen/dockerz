variable "aws_region" {
}

variable "z_region" {
}

variable "z_domain" {
}

variable "ssh_key_name" {
}

variable "ssh_key_filename" {
}

variable "z_zone_id" {
}

variable "amis" {
  type = "map"
}

variable "vpc_key" {
  description = "A unique identifier for the VPC."
  default     = "dockerz"
}

variable "cluster_manager_count" {
    description = "Number of manager instances for the swarm cluster."
    default = 1
}

variable "cluster_node_count" {
    description = "Number of node instances for the swarm cluster."
    default = 1
}

variable "cluster_control_count" {
    description = "Number of service control instances for the flocker cluster."
    default = 1
}
