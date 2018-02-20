variable "aws_region" {
}

variable "z_region" {
}

variable "z_network" {
}

variable "z_domain" {
}

variable "ssh_key_name" {
}

variable "ssh_key_filename" {
}

variable "z_zone_id" {
}

variable "certificate" {
}

variable "vpc_cidr_block" {
}

variable "amis" {
  type = "map"
}

variable "vpc_key" {
  description = "A unique identifier for the VPC."
}

variable "cluster_manager_count" {
    description = "Number of manager instances for the swarm cluster."
    default = 1
}

variable "cluster_storage_count" {
    description = "Number of storage instances for the swarm cluster."
    default = 3
}

variable "cluster_app_count" {
    description = "Number of app instances for the swarm cluster."
    default = 1
}

