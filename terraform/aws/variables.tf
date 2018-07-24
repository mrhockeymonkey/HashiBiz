variable access_key {
  description = "aws access key"
}

variable secret_key {
  description = "aws secret key"
}

variable "region" {
  description = "the aws region to provision"
  default     = "eu-west-2"                   # london
}

variable "hashibiz-ami-web" {
  description = "the id for the hashibiz website image"
  default     = "ami-0f0d164908ab52ed9"
}
