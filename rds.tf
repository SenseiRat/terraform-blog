resource "aws_db_instance" "wp_db" {
  allocated_storage    = var.db_storage
  engine               = "mysql"
  engine_version       = "8.0.17"
  instance_class       = var.db_instance_class
  name                 = var.dbname
  username             = var.dbuser
  password             = var.dbpassword
  db_subnet_group_name = aws_db_subnet_group.wp_rds_subnetgroup.name
  vpc_security_group_ids = [
    aws_security_group.wp_rds_sg.id
  ]
  skip_final_snapshot = true
}
