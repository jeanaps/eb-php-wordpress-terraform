resource "aws_elastic_beanstalk_application" "dev" {
  name        = "${var.project_name}"
  description = "AWS Elastic Beanstalk Application"
}

resource "aws_elastic_beanstalk_environment" "dev" {
  name                = "${var.project_name}"
  application         = "${aws_elastic_beanstalk_application.dev.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.8.11 running PHP 7.2"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_DB_NAME"
    value     = "${var.rds_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_HOSTNAME"
    value     = "${aws_db_instance.dev.address}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PORT"
    value     = "${var.rds_port}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_USERNAME"
    value     = "${var.rds_username}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PASSWORD"
    value     = "${var.rds_password}"
  }
}

resource "aws_elastic_beanstalk_application_version" "dev" {
  name        = "${var.project_version}"
  application = "${var.project_name}"
  description = "AWS Elastic Beanstalk Application Version"
  bucket      = "${aws_s3_bucket.dev.id}"
  key         = "${aws_s3_bucket_object.dev.id}"
}
