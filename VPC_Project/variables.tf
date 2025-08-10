variable "region" {
  description = "What region do we use, sir?"
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Enter Instance type"
  default     = "t3.micro"
}

variable "trusted_ips" {
  type    = list(string)
  default = ["83.99.252.228/32"]
}

/*variable "allow ports" {
  description = "List of Ports to open for server"
  type        = list(string)
  default     = ""
}*/