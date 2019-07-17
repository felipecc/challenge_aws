variable "region" {
    default = "us-east-1"
    #default = "us-east-2"
}


variable "cidr_block" {
  default = "10.10.0.0/16"
}

variable "bucket_name" {
  default =  "com.challengetiendanube.dev.terraform" 
}

variable "dynamodb_table_name" {
  default =  "terraform_dev"
}



    