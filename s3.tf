resource "aws_s3_bucket" "dev" {
  bucket = "${var.bucket_name}"
}

resource "aws_s3_bucket_object" "dev" {
  bucket = "${aws_s3_bucket.dev.id}"
  key    = "beanstalk/${var.project_source}"
  source = "${var.project_source}"
}
