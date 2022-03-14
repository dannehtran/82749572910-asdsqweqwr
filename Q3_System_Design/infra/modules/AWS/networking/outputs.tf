output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "pub_1_subnet" {
    value = aws_subnet.pub_1_subnet.id
}

output "pub_2_subnet" {
    value = aws_subnet.pub_2_subnet.id
}