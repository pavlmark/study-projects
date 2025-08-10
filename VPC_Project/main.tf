# ----------------------------------------------
#
# VPC for study project
#
# Created by me and terraform docs and ChatGPT
#
# 31.07.25
# ----------------------------------------------

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Riga-network" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Riga-Network-VPC"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  tags = {
    Name = "Bastion Host VPC-Riga"
  }
}

#=========================================================
# NAT Gateway
#=========================================================
resource "aws_internet_gateway" "Riga-VPC-IGW" {
  vpc_id = aws_vpc.Riga-network.id

  tags = {
    Name = "Riga-IGW"
  }
}

resource "aws_nat_gateway" "NAT-GW-Subnet-A" {
  allocation_id = aws_eip.NAT-GW-Subnet-A.id
  subnet_id     = aws_subnet.Riga-Private-Subnet-A.id
  #depends_on    = [aws_eip.NAT-GW-Subnet-A] # Now it works

  tags = {
    Name = "NAT-GW-Subnet-A"
  }
}

resource "aws_nat_gateway" "NAT-GW-Subnet-B" {
  allocation_id = aws_eip.NAT-GW-Subnet-B.id
  subnet_id     = aws_subnet.Riga-Private-Subnet-B.id
  #depends_on    = [aws_eip.NAT-GW-Subnet-B] # Now it works

  tags = {
    Name = "NAT-GW-Subnet-B"
  }
}

resource "aws_eip" "NAT-GW-Subnet-A" {
  tags = {
    Name = "eip-for-nat-A"
  }
}

resource "aws_eip" "NAT-GW-Subnet-B" {
  tags = {
    Name = "eip-for-nat-B"
  }
}
#=====================================================
# Route Tables
#=====================================================
resource "aws_route_table" "Public-RouteTable-A" {
  vpc_id = aws_vpc.Riga-network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Riga-VPC-IGW.id
  }

  tags = {
    Name = "Public-RouteTable-A"
  }
}

resource "aws_route_table" "Public-RouteTable-B" {
  vpc_id = aws_vpc.Riga-network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Riga-VPC-IGW.id
  }

  tags = {
    Name = "Public-RouteTable-B"
  }
}

resource "aws_route_table" "Private-RouteTable-A" {
  vpc_id = aws_vpc.Riga-network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW-Subnet-A.id
  }

  tags = {
    Name = "Route Table to Private Subnet-A"
  }
}

resource "aws_route_table" "Private-RouteTable-B" {
  vpc_id = aws_vpc.Riga-network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW-Subnet-B.id
  }

  tags = {
    Name = "Route Table to Private Subnet-B"
  }
}

resource "aws_route_table" "DB-RouteTable" {
  vpc_id = aws_vpc.Riga-network.id

  tags = {
    Name = "Route Table to DB Subnet"
  }
}

resource "aws_route_table_association" "Route-Public-A" {
  subnet_id      = aws_subnet.Riga-Public-Subnet-A.id
  route_table_id = aws_route_table.Public-RouteTable-A.id
}

resource "aws_route_table_association" "Route-Public-B" {
  subnet_id      = aws_subnet.Riga-Public-Subnet-B.id
  route_table_id = aws_route_table.Public-RouteTable-B.id
}

resource "aws_route_table_association" "Route-Private-A" {
  subnet_id      = aws_subnet.Riga-Private-Subnet-A.id
  route_table_id = aws_route_table.Private-RouteTable-A.id
}

resource "aws_route_table_association" "Route-Private-B" {
  subnet_id      = aws_subnet.Riga-Private-Subnet-B.id
  route_table_id = aws_route_table.Private-RouteTable-B.id
}

resource "aws_route_table_association" "Route-DB-A" {
  subnet_id      = aws_subnet.Riga-DB-Subnet-A.id
  route_table_id = aws_route_table.DB-RouteTable.id
}

resource "aws_route_table_association" "Route-DB-B" {
  subnet_id      = aws_subnet.Riga-DB-Subnet-B.id
  route_table_id = aws_route_table.DB-RouteTable.id

}

#=====================================================
#AutoScalingGroup
#=====================================================

resource "aws_autoscaling_group" "AutoScalingGroup-for-VPC-Riga" {
  vpc_zone_identifier       = [aws_subnet.Riga-Public-Subnet-A.id, aws_subnet.Riga-Public-Subnet-B.id]
  name                      = "ASG-Riga-VPC-Project"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 30
  desired_capacity          = 1
  force_delete              = true
  launch_template {
    id      = aws_launch_template.VPC-Riga-ASG.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-Riga-VPC-Project"
    propagate_at_launch = true
  }

  tag {
    key                 = "Enviroment"
    value               = "study"
    propagate_at_launch = true
  }

}

resource "aws_launch_template" "VPC-Riga-ASG" {
  name          = "Riga-VPC-Launch-Template"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = "EC2 Tutorial"

  tags = {
    Name       = "Riga-VPC-ASG-Instances"
    Enviroment = "study"
  }


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.SG-Bastion-Host.id]
  }

}

#=====================================================
# Subnets
#=====================================================

resource "aws_subnet" "Riga-Public-Subnet-A" {
  vpc_id                  = aws_vpc.Riga-network.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Riga-Public-Subnet-A"
  }
}

resource "aws_subnet" "Riga-Public-Subnet-B" {
  vpc_id                  = aws_vpc.Riga-network.id
  cidr_block              = "10.0.21.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Riga-Public-Subnet-B"
  }
}

resource "aws_subnet" "Riga-Private-Subnet-A" {
  vpc_id            = aws_vpc.Riga-network.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Riga-Private-Subnet-A"
  }
}

resource "aws_subnet" "Riga-Private-Subnet-B" {
  vpc_id            = aws_vpc.Riga-network.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Riga-Private-Subnet-B"
  }
}

resource "aws_subnet" "Riga-DB-Subnet-A" {
  vpc_id            = aws_vpc.Riga-network.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Riga-DB-Subnet-A"
  }
}

resource "aws_subnet" "Riga-DB-Subnet-B" {
  vpc_id            = aws_vpc.Riga-network.id
  cidr_block        = "10.0.23.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Riga-DB-Subnet-B"
  }
}
# ======================================================================

#============================================================
# Security Group for Bastion Host
# ===========================================================
resource "aws_security_group" "SG-Bastion-Host" {
  name        = "Bastion Host Remote Access"
  description = "My First Terraform SG"
  vpc_id      = aws_vpc.Riga-network.id

  ingress {
    description = "Bastion-Host-SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ==========================================================
