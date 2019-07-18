variable "region" {
    default = "us-east-1"
    #default = "us-east-2"
}


variable "cidr_block" {
  default = "10.10.0.0/16"
}

variable "cidr_block_subnet_a" {
  default = "10.10.1.0/24"
}

variable "cidr_block_subnet_b" {
  default = "10.10.2.0/24"
}




variable "bucket_name" {
  default =  "com.challengetiendanube.dev.terraform" 
}

variable "dynamodb_table_name" {
  default =  "terraform_dev"
}



    