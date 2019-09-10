resource "aws_security_group" "asg_security_group" {
  name   = "${local.stack_name}-security-group-asg"
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.public_subnet.*.cidr_block}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      Name    = "${local.stack_name}_security-group-asg"
      Release = "${var.release_name}"
      Version = "${var.release_version}"
    },
  ]
}

resource "aws_security_group_rule" "asg_ingress" {
  type              = "ingress"
  from_port         = "${var.service_port}"
  to_port           = "${var.service_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${aws_subnet.public_subnet.*.cidr_block}"]
  security_group_id = "${aws_security_group.asg_security_group.id}"
}

resource "aws_security_group" "elb_security_group" {
  name   = "${local.stack_name}-security-group-elb"
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      Name    = "${local.stack_name}_security-group-elb"
      Release = "${var.release_name}"
      Version = "${var.release_version}"
    },
  ]
}

resource "aws_security_group_rule" "elb_ingress" {
  type              = "ingress"
  from_port         = "${var.service_port}"
  to_port           = "${var.service_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_security_group.id}"
}
