variable "aws_region" {
  description = "EC2 Region"
  default     = "us-east-2"
}

variable "aws_access_key" {
  description = "AWS Access Key; required by Terraform to create/destroy the resources"
}

variable "aws_secret_key" {
  description = "AWS Secret Key; required by Terraform to create/destroy the resources"
}

variable "project_name" { 
  description = "Name of the project (lowercase bc S3 doesn't like uppercase)"
  default     = "my-project"
}

variable "project_version" { 
  description = "Application Version (Elastic Beanstalk); env. var. exported from build.sh script"
}

variable "project_source" { 
  description = "Application Source (Elastic Beanstalk); env. var. exported from build.sh script"
}

variable "bucket_name" { 
  description = "S3 Bucket to store Application Source (Elastic Beanstalk) and other Application data (i.e., Data Lake for Analytics)"
}

variable "rds_name" {
  description = "Name of the RDS DB"
  default = "ebdb"
}

variable "rds_port" {
  description = "Port of the RDS DB"
  default = "5432"
}

variable "rds_username" {
  description = "Username of the RDS DB"
}

variable "rds_password" {
  description = "Password of the RDS DB"
}
