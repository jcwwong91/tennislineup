variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the k8s nodes"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}
