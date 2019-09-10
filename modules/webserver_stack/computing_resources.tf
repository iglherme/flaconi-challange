resource "aws_launch_configuration" "lc" {
  name                 = "${local.stack_name}_lc"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_groups      = ["${aws_security_group.asg_security_group.id}"]
  user_data_base64     = "${var.user_data_base64}"
}

resource "aws_autoscaling_group" "asg" {
  depends_on                = ["aws_lb.load_balancer"]
  name                      = "${local.stack_name}_asg"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  default_cooldown          = "${var.default_cooldown}"
  launch_configuration      = "${aws_launch_configuration.lc.name}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  desired_capacity          = "${var.desired_capacity}"
  force_delete              = "${var.force_delete}"
  target_group_arns         = ["${aws_lb_target_group.target_group.arn}"]
  termination_policies      = "${var.termination_policies}"
  metrics_granularity       = "${var.metrics_granularity}"
  enabled_metrics           = "${var.enabled_metrics}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  vpc_zone_identifier       = ["${aws_subnet.private_subnet.*.id}"]

  tags = [
    {
      key                 = "Name"
      value               = "${local.stack_name}-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Description"
      value               = "Deployment Instance"
      propagate_at_launch = true
    },
    {
      key                 = "Release"
      value               = "${var.release_name}"
      propagate_at_launch = true
    },
    {
      key                 = "Version"
      value               = "${var.release_version}"
      propagate_at_launch = true
    },
  ]
}

# Scaling UP - CPU High
resource "aws_autoscaling_policy" "cpu_high" {
  name                   = "${local.stack_name}-high-cpu"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "1"
  cooldown               = "${var.default_cooldown}"
}

# Scaling DOWN - CPU Low
resource "aws_autoscaling_policy" "cpu_low" {
  name                   = "${local.stack_name}-low-cpu"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "-1"
  cooldown               = "${var.default_cooldown}"
}
