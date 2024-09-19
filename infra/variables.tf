variable "aws_access_key" {
  description = "AWS Acccess Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret key"
  type        = string
}

variable "aws_region" {
  description = "Region to spin up instance"
  type        = string
}

variable "ami" {
  description = "AMI for instance to be used"
  type        = string
  default     = "ami-0e806decb501416d7"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "birdAPI"
}

variable "key_name" {
  description = "EC2 Key pair for SSH access"
  type        = string
}

variable "disk_size" {
  description = "EC2 disk size"
  type        = string
}

variable "my_ip" {
  description = "Public IP address to allow SSH access"
  type        = string
}