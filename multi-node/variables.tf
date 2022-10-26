variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS deployment region."
}

variable "avail_zone" {
  type        = string
  default     = "us-west-2a"
  description = "The AWS availability zone location within the selected region (i.e. us-east-2a)."
}

variable "my_ip" {
  type        = string
  default     = "<MY_PUBLIC_IP_ADDRESS>"
  description = "My public IP address."
}

variable "my_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "instance_type" {
  type        = string
  default     = "t2.xlarge"
  description = "The instance type to provision the instances from (i.e. p2.xlarge)."
}

variable "spot_price" {
  type        = string
  default     = "0.12"
  description = "Highest hourly price we are willing to pay for the specified instance, i.e. 0.10. This price should not be below AWS' minimum spot price for the instance based on the region."
}

variable "ebs_volume_size" {
  type        = string
  default     = "100" # in gigabytes
  description = "The Amazon EBS volume size (1 GB - 16 TB)."
}

variable "num_instances" {
  type        = string
  default     = "5"
  description = "Number of EC2 instances."
}
