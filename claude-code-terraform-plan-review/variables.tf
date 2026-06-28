variable "instance_name" {
  type    = string
  default = "review-demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ami_id" {
  type    = string
  default = "ami-0d52744d6551d851e"
}
