variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the k3s node"
  type        = string
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "eic_sg_id" {
  description = "Security group ID of the EC2 Instance Connect Endpoint"
  type        = string
}
