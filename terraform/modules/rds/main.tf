resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    var.rds_security_group_id
  ]

  publicly_accessible = false

  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
