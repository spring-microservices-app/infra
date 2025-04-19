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
  default = "t2.micro"
}
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}
variable "stock_service_jar_url" {
  description = "URL to the stock service JAR file"
  type        = string
}
variable "mongodb_uri" {
  description = "MongoDB URI"
  type        = string
}
variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string  
}
variable "eureka_url" {
  description = "Eureka server URL"
  type        = string

}
