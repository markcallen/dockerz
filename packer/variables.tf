variable "vpc_key" {
  description = "A unique identifier for the VPC."
  default     = "marka-packer"
}

variable "public_ip" {
  description = "The public ip for the current machine"
  default     = "0.0.0.0/0"
}
