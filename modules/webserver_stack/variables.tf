#---------------------------
# General resources variables
#---------------------------
variable "release_name" {
  description = "Name of the Release / Stack"
}

variable "release_version" {
  description = "Version of the Release / Stack"
}

locals {
  stack_name = "${var.release_name}-${var.release_version}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

#---------------------------
# Network resources variables
#---------------------------
variable "cidr_block" {
  type        = "string"
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "enable_https" {
  type        = "string"
  description = "Enable or disable HTTPS on the Load Balancer"
}

variable "service_port" {
  type        = "string"
  description = "The port that the webservice expose the application"
}

variable "certificate_arn" {
  type        = "string"
  default     = ""
  description = "ARN of the certificate on ACM"
}

#---------------------------
# Computing resources variables
#---------------------------

variable "image_id" {
  description = "The EC2 image ID to launch."
}

variable "instance_type" {
  description = "The size of instance to launch."
}

variable "iam_instance_profile" {
  description = "The name attribute of the IAM instance profile to associate with launched instances."
  default     = ""
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  default     = ""
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  default     = ""
}

variable "max_size" {
  description = "The maximum size of the auto scale group."
  type        = "string"
}

variable "min_size" {
  description = "The minimum size of the auto scale group. (See also Waiting for Capacity.)"
  type        = "string"
  default     = "1"
}

variable "default_cooldown" {
  description = "Time (in seconds) after a scaling activity completes before another scaling activity can start."
  type        = "string"
  default     = 300
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health."
  type        = "string"
  default     = 300
}

variable "health_check_type" {
  description = "\"EC2\" or \"ELB\". Controls how health checking is done."
  default     = "EC2"
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group. (See also Waiting for Capacity.)"
  type        = "string"
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling."
  type        = "string"
  default     = false
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = "list"
  default     = ["Default"]
}

variable "metrics_granularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute. Default is 1Minute."
  default     = "1Minute"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances."
  type        = "list"
  default     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out (See also Waiting for Capacity.) Setting this to \"0\" causes Terraform to skip all Capacity Waiting behavior (Default: \"10m\")."
  default     = "10m"
}

variable "min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes."
  type        = "string"
  default     = "1"
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations."
  type        = "string"
  default     = "1"
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  type        = "string"
  default     = false
}