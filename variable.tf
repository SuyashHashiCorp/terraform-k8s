##AWS instance Key Pair File
variable "key_pair" {
  type = map(string)
  default = {
    "key_name"   = "<public_key_name>"
    "public_key" = "<public_key_value>"
  }
}

variable "key_path" {
  default = "<pem_file_path>/<pem_file_name.pem>"
}

#EC2
variable "ami" {
  default = "ami-0fb653ca2d3203ac1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "master_instance_name" {
  type    = list(string)
  default = ["master1"]
}

variable "master_private_ip" {
  type    = list(any)
  default = ["10.0.1.100"]
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_instance_name" {
  type    = list(any)
  default = ["node1", "node2"]
}

variable "node_private_ip" {
  type = list(any)
  default = [ "10.0.1.101", "10.0.1.102" ]
}

variable "node_name" {
  type    = list(any)
  default = ["node1", "node2"]
}

#VPC
variable "subnet" {
  type    = string
  default = "<subnet_id>" #Please make sure this subnet has accessibility to internet. Please use public subnet#
}

variable "sg_id" {
  type = list(any)
  default = ["<security_group_id>"] #Please see security group table in GIT README.md file for port details.
}


#UserPaths
variable "scriptpaths" {
  type = string
  default = "/Users/suyash/Projects/terraform-k8s/scripts/" #Update this path with your path where you cloned the git repository
}

#UserScripts
variable "k8sconfigpaths" {
  type    = string
  default = "/Users/suyash/Projects/terraform-k8s/configs/" #Update this path with your path where you cloned the git repository
}
