variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}
variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}
variable "instance_type" {
  default = "t4g.medium" # ARM64 instance type for ElasticSearch
  description = "Instance type"
  type        = string
}
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "public_elastic_ip_allocation_id" {
  description = "Elastic IP allocation ID"
  type        = string
  
}