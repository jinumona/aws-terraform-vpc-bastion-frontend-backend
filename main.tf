# vim main.tf

# creating vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
    enable_dns_hostnames = true
    

  tags = {
    Name = "${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

# Adding Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

 tags = {
    Name = "${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
    
}

# Creating public subnets

resource "aws_subnet" "public1" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr,3,0)
    availability_zone = data.aws_availability_zones.az.names[0]
    map_public_ip_on_launch = true

 tags = {
      Name = "public1-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

resource "aws_subnet" "public2" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr,3,1)
    availability_zone = data.aws_availability_zones.az.names[1]
    map_public_ip_on_launch = true

 tags = {
      Name = "public2-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

resource "aws_subnet" "public3" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr,3,2)
    availability_zone = data.aws_availability_zones.az.names[2]
    map_public_ip_on_launch = true

 tags = {
      Name = "public3-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}


# Creating 3 private subnets


resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,3)
    availability_zone = data.aws_availability_zones.az.names[0]

 tags = {
    Name = "private1-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,4)
    availability_zone = data.aws_availability_zones.az.names[1]

 tags = {
    Name = "private2-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,5)
    availability_zone = data.aws_availability_zones.az.names[0]

 tags = {
    Name = "private3-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}

#------------------------------------

# Creating Elastic Ip

resource "aws_eip" "natgw" {
  vpc      = true
}

#-------------------------------------
# Creating Nat gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public1.id

tags = {
    Name = "nat-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#--------------------------

# Creating Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

 tags = {
    Name = "public-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}


# Creating Private Route Table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

 tags = {
    Name = "private-${var.project}-${var.env}"
      project = var.project
      env = var.env
  }
}


# Public Route table Association for subnets

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}

# Private Route table Association for subnets

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}

#------------------
# Creating Security Group For bastion

resource "aws_security_group" "bastion" {
 name_prefix        = "bastion-${var.project}-${var.env}-"
  description = "Allow 22"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "bastion-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}


# Creating Security Group For frontend

resource "aws_security_group" "frontend" {
 name_prefix        = "frontend-${var.project}-${var.env}-"
  description = "Allow 22,80,443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
    
     ingress {
    description      = "allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    
     ingress {
    description      = "allow 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "frontend-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}

# Creating Security Group For backend

resource "aws_security_group" "backend" {
 name_prefix        = "backend-${var.project}-${var.env}-"
  description = "Allow 22,3306"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
    
     ingress {
    description      = "allow 3306"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
    
      egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
   
    tags = {
    
    Name = "backend-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}


# creating key pair

resource "aws_key_pair" "key" {
  key_name   = "${var.project}-${var.env}"
  public_key = file("localkey.pub")
    
    tags = {
    
    Name = "${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}

#creating bastion instance

resource "aws_instance" "bastion" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = aws_subnet.public1.id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "bastion-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}

#creating front end instance

resource "aws_instance" "frontend" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  subnet_id = aws_subnet.public2.id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "frontend-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}



#creating backend instance


resource "aws_instance" "backend" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.backend.id]
  subnet_id = aws_subnet.private1.id
  user_data_replace_on_change = true
    
    
 tags = {
    
    Name = "backend-${var.project}-${var.env}"
    project = var.project
    env = var.env
}
}


