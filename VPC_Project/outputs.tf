output "vpc_id" {
  value = aws_vpc.Riga-network.id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.Riga-VPC-IGW.id
}

output "aws_security_group" {
  value = aws_security_group.SG-Bastion-Host.id
}

output "aws_subnet-public-A" {
  value = aws_subnet.Riga-Public-Subnet-A.id
}

output "aws_subnet-public-B" {
  value = aws_subnet.Riga-Public-Subnet-B.id
}

output "aws_subnet-private-A" {
  value = aws_subnet.Riga-Private-Subnet-A.id
}

output "aws_subnet-private-B" {
  value = aws_subnet.Riga-Private-Subnet-B.id
}

output "aws_subnet-database-A" {
  value = aws_subnet.Riga-DB-Subnet-A.id
}

output "aws_subnet-database-B" {
  value = aws_subnet.Riga-DB-Subnet-B.id
}

output "aws_nat_gateway-A" {
  value = aws_nat_gateway.NAT-GW-Subnet-A.id
}

output "aws_nat_gateway-B" {
  value = aws_subnet.Riga-Public-Subnet-B.id
}

output "aws_route_table-Public-A" {
  value = aws_internet_gateway.Riga-VPC-IGW.id
}

output "aws_route_table-A" {
  value = aws_route_table.Private-RouteTable-A.id
}

output "aws_route_table-B" {
  value = aws_route_table.Private-RouteTable-B.id
}

output "aws_autoscaling_group" {
  value = aws_autoscaling_group.AutoScalingGroup-for-VPC-Riga.id
}

output "aws_launch_template" {
  value = aws_launch_template.VPC-Riga-ASG
}