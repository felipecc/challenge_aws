module "dev-tfstate" {
  source = "github.com/confluentinc/terraform-state"
  env = "dev"
  s3_bucket = "com.challengetiendanube.dev.terraform"
  s3_bucket_name = "Dev Terraform State Store"
  dynamodb_table = "terraform_dev"
}