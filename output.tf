# subnets

output "public1_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,0)
}

output "public2_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,1)
}

output "public3_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,2)
}

output "private1_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,3)
}

output "private2_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,4)
}

output "private3_subnet" {
    value = cidrsubnet(var.vpc_cidr,3,5)
}

# availability zones

output "az1" {
    value = data.aws_availability_zones.az.names[0]
}

output "az2" {
    value = data.aws_availability_zones.az.names[1]
}

output "az3" {
    value = data.aws_availability_zones.az.names[2]
}


