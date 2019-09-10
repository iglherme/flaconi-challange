output "lb_endpoint_address" {
  description = "The DNS name for the Load Balancer"
  value       = "${aws_lb.load_balancer.dns_name}"
}

output "vpc_id" {
  description = "The id of the VPC"
  value       = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  description = "The id of the public subnet"
  value       = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnet_ids" {
  description = "The id of the private subnet2"
  value       = "${aws_subnet.private_subnet.*.id}"
}

output "nat_eip" {
  description = "The public IP of the NAT EIP."
  value       = "${aws_eip.nat_gateway.public_ip}"
}
