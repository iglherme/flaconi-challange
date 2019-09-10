# AWS Webserver Stack Module

Terraform module which creates the following AWS resources:

* VPC 
* Public and Private Subnets
* NAT
* Application Load Balancer 
* InternetGateway
* Security Groups
* Auto Scaling Group
* Launch configuration

Root module calls these modules which can also be used separately to create independent resources.

## Terraform versions

Terraform 0.12. 

Terraform 0.11. 

## Environment Configuration

This module require access to AWS provider. Use the following variables to use it:
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```

## How to Use

To create a stack from the root example, run:
```bash
$ terraform init
$ terraform apply
```

To destroy the stack, run:
```bash
$ terraform destroy
```

## Exanmples

To create a stack with a custom ami

```hcl
module "webserver_stack" {
  source           = "./modules/webserver_stack"
  desired_capacity = "2"
  enable_https     = "false"
  image_id         = "ami-009b8e80f78d8be17"
  instance_type    = "t2.micro"
  max_size         = "2"
  release_name     = "nginx"
  release_version  = "1.0.0"
  service_port     = "80"
}
```

To create a stack listening HTTP and HTTPS

```hcl
module "webserver_stack" {
  source           = "./modules/webserver_stack"
  desired_capacity = "2"
  enable_https     = "true"
  image_id         = "ami-009b8e80f78d8be17"
  instance_type    = "t2.micro"
  max_size         = "2"
  release_name     = "nginx"
  release_version  = "1.0.0"
  service_port     = "80"
  certificate_arn  = "arn:acm:1234567890-1234567890"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| certificate\_arn | ARN of the certificate on ACM | string | `""` | no |
| cidr\_block | The CIDR block for the VPC | string | `"10.0.0.0/16"` | no |
| default\_cooldown | Time (in seconds) after a scaling activity completes before another scaling activity can start. | string | `"300"` | no |
| desired\_capacity | The number of Amazon EC2 instances that should be running in the group. (See also Waiting for Capacity.) | string | n/a | yes |
| enable\_https | Enable or disable HTTPS on the Load Balancer | string | n/a | yes |
| enabled\_metrics | A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances. | list | `<list>` | no |
| force\_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling. | string | `"false"` | no |
| health\_check\_grace\_period | Time (in seconds) after instance comes into service before checking health. | string | `"300"` | no |
| health\_check\_type | "EC2" or "ELB". Controls how health checking is done. | string | `"EC2"` | no |
| iam\_instance\_profile | The name attribute of the IAM instance profile to associate with launched instances. | string | `""` | no |
| image\_id | The EC2 image ID to launch. | string | n/a | yes |
| instance\_type | The size of instance to launch. | string | n/a | yes |
| max\_size | The maximum size of the auto scale group. | string | n/a | yes |
| metrics\_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute. Default is 1Minute. | string | `"1Minute"` | no |
| min\_elb\_capacity | Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes. | string | `"1"` | no |
| min\_size | The minimum size of the auto scale group. (See also Waiting for Capacity.) | string | `"1"` | no |
| protect\_from\_scale\_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events. | string | `"false"` | no |
| release\_name | Name of the Release / Stack | string | n/a | yes |
| release\_version | Version of the Release / Stack | string | n/a | yes |
| service\_port | The port that the webservice expose the application | string | n/a | yes |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default. | list | `<list>` | no |
| user\_data | The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead. | string | `""` | no |
| user\_data\_base64 | Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption. | string | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out (See also Waiting for Capacity.) Setting this to "0" causes Terraform to skip all Capacity Waiting behavior (Default: "10m"). | string | `"10m"` | no |
| wait\_for\_elb\_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations. | string | `"1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| lb\_endpoint\_address | The DNS name for the Load Balancer |
| nat\_eip | The public IP of the NAT EIP. |
| private\_subnet\_ids | The id of the private subnet2 |
| public\_subnet\_ids | The id of the public subnet |
| vpc\_id | The id of the VPC |

