resource "aws_db_instance" "dev" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "${var.rds_name}"
  port                 = "${var.rds_port}"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  skip_final_snapshot  = "true"
}
