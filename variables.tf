# 1. Networking Variables
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "The vpc_cidr_block must be a valid CIDR."
  }
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  validation {
    condition     = can(cidrnetmask(var.subnet_cidr_block))
    error_message = "The subnet_cidr_block must be a valid CIDR."
  }
}

variable "availability_zone" {
  description = "The AWS AZ to deploy resources"
  type        = string
}

# 2. General Settings
variable "env_prefix" {
  description = "Prefix for resource naming (e.g., dev, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

# 3. Security & SSH
variable "public_key" {
  description = "Path to your public SSH key (e.g., ./id_ed25519.pub)"
  type        = string
}

variable "private_key" {
  description = "Path to your private SSH key (e.g., ./id_ed25519)"
  type        = string
}