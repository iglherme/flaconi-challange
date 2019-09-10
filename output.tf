output "lb_endpoint_address" {
  description = "The DNS name for the Load Balancer"
  value       = "${module.webserver_stack.lb_endpoint_address}"
}

output "vpc_id" {
  description = "The id of the VPC"
  value       = "${module.webserver_stack.vpc_id}"
}

output "public_subnet_ids" {
  description = "The id of the public subnet"
  value       = "${module.webserver_stack.public_subnet_ids}"
}

output "private_subnet_ids" {
  description = "The id of the private subnet2"
  value       = "${module.webserver_stack.private_subnet_ids}"
}

output "nat_eip" {
  description = "The public IP of the NAT EIP."
  value       = "${module.webserver_stack.nat_eip}"
}
