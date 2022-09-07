variable "region" {
    default = "ap-south-1"
}

variable "instance_type" {
    
    default = "t2.micro"
}

variable "instance_ami" {
    
    default = "ami-06489866022e12a14"
}

variable "project" {
    default = "zomato"
}

variable "env" {
    default = "dev"
}

variable "vpc_cidr" {
    default = "172.16.0.0/16"
}
