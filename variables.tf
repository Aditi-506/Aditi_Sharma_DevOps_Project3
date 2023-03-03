variable "region" {
  default = "us-east-1"
}

variable "av_zone" {
  default = "us-east-1a"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-006dcf34c09e50022"
}

variable "cidr_block" {
  default = "172.31.0.0/16"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  default = "vpc-043c8127da2fb863d"
}
