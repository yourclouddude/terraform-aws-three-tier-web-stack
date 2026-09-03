output "application_subnet_ids" {
  value = [for index in range(length(var.availability_zones)) : aws_subnet.application[tostring(index)].id]
}

output "database_subnet_ids" {
  value = [for index in range(length(var.availability_zones)) : aws_subnet.database[tostring(index)].id]
}

output "public_subnet_ids" {
  value = [for index in range(length(var.availability_zones)) : aws_subnet.public[tostring(index)].id]
}

output "vpc_id" {
  value = aws_vpc.this.id
}
