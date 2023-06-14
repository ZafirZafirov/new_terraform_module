variable "region" {
  type = string
  default = "eu-west-1"
}

variable "subnet_type" {
  default = {
    public  = "public"
    private = "private"
  }
}
variable "cidr_ranges" {
  default = {
    public1  = "172.16.1.0/24"
    public2  = "172.16.3.0/24"
    private1 = "172.16.4.0/24"
    private2 = "172.16.5.0/24"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "ec2_instance_name" {
  type = string
}

variable "number_of_instances" {
  type = number
}