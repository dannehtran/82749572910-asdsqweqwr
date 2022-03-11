output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "priv_1_subnet" {
    value = aws_subnet.priv_1_subnet.id
}

output "priv_2_subnet" {
    value = aws_subnet.priv_2_subnet.id
}