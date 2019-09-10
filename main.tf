provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

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
