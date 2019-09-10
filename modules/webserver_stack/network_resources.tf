resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${local.stack_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr_block,8,1+count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = [
    {
      Name        = "${local.stack_name}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
      Description = "Public subnet"
    },
  ]
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr_block,8,10+count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = [
    {
      Name        = "${local.stack_name}-private-subnet-${data.aws_availability_zones.available.names[count.index]}"
      Description = "Private subnet zone ${data.aws_availability_zones.available.names[count.index]}"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = [
    {
      Name        = "${local.stack_name}-ig"
      Description = "Internet gateway"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_gateway.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"

  tags = [
    {
      Name        = "${local.stack_name}-nat-gateway"
      Description = "Public facing NAT gateway"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_route_table" "public_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }

  tags = [
    {
      Name        = "${local.stack_name}-public-route-table"
      Description = "Routing table for public subnet"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_route_table_association" "public_subnet" {
  count          = 2
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_subnet.id}"
}

resource "aws_route_table" "private_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags = [
    {
      Name        = "${local.stack_name}-ptivate-route-table"
      Description = "Routing table for private subnet"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_route_table_association" "private_subnet" {
  count          = 2
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_subnet.id}"
}

resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = [
    {
      Name        = "${local.stack_name}-elastic-ip-nat-gateway"
      Description = "Elastic IP for public facing NAT instance"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_lb_target_group" "target_group" {
  name     = "lb-target-group"
  port     = "${var.service_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.target_group.arn}"
}

resource "aws_lb" "load_balancer" {
  depends_on         = ["aws_nat_gateway.nat_gateway"]
  name               = "alb-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elb_security_group.id}"]
  subnets            = ["${aws_subnet.public_subnet.*.id}"]

  tags = [
    {
      Name        = "${local.stack_name}-elb"
      Description = "Elastic Load Balancer for public facing NAT instance"
      Release     = "${var.release_name}"
      Version     = "${var.release_version}"
    },
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}

resource "aws_lb_listener" "https" {
  count             = "${var.enable_https == true ? 1 : 0}"
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}
