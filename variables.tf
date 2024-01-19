variable "cidr_block" {
  type = list(string)
  default = ["172.20.0.0/16","172.20.10.0/24"]
}

variable "ports" {
  type = list(number)
  default = [22,443,80,8080,8081]
}
variable "ami" {
  type = string
  default = "ami-00dfe2c7ce89a450b"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "instance_type_for_nexus" {
  type = string
  default = "t2.medium"
}
