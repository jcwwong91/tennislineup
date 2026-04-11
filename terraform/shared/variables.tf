variable "my_ip" {
  description = "Your IP address for SSH access (e.g. 1.2.3.4)"
  type        = string
}

variable "public_key" {
  description = "SSH public key for EC2 access (contents of ~/.ssh/your-key.pub)"
  type        = string
}
