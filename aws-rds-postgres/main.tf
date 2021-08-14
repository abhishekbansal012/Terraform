locals {
    password    = compact([var.password, random_password.this.result])[0]
    secret_name = join("_",["RDS", upper(var.name), "PASSWORD"])
    secret      = {"${local.secret_name}" : "${local.password}"}

    # Adaption of User Paramaters; Parameters already set in default will be removed.
    adapted_parameters = flatten([
      for d in local.default_parameters: [
        for dk, dv in d : [ 
          for c in var.parameters: [
            for ck, cv in c : c if ck == "name" && ck == dk && cv != dv
          ]
        ]
      ]
    ])

    # Merge of default and custom parameters
    parameters = concat(local.default_parameters, local.adapted_parameters)
}

# ---------------------------------------------------------------------------------------------------------------------
# Password Management
# ---------------------------------------------------------------------------------------------------------------------
resource "random_password" "this" {
  length           = 25
  special          = false
}

data "aws_secretsmanager_secret" "this" {
    arn = var.secretmanager_secret_arn
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id      = data.aws_secretsmanager_secret.this.id
  secret_string  = jsonencode(local.secret)
  version_stages = ["AWSCURRENT"]
}


# ---------------------------------------------------------------------------------------------------------------------
# RDS Postgres
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier_prefix         = var.identifier_prefix
  port                      = var.port
  allocated_storage         = var.allocated_storage     
  max_allocated_storage     = var.max_allocated_storage 
  storage_type              = var.storage_type          
  iops                      = var.storage_type != "io1" ? 0 : var.iops                  
  engine                    = "postgres"
  engine_version            = var.engine_version        
  allow_major_version_upgrade = var.allow_major_version_upgrade 
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade  
  instance_class            = var.instance_class 
  enabled_cloudwatch_logs_exports  = var.enabled_cloudwatch_logs_exports
  monitoring_interval       = var.monitoring_interval
  monitoring_role_arn       = var.monitoring_interval > 0 ? aws_iam_role.this.*.arn[0] : null


  name                   = var.name
  username               = var.username
  password               = local.password
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  storage_encrypted      = true
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  delete_automated_backups = var.delete_automated_backups
  maintenance_window     = var.maintenance_window
  multi_az               = var.multi_az
  parameter_group_name   = aws_db_parameter_group.this.name
  deletion_protection    = var.deletion_protection
  tags                   = var.tags

  #checkov:skip=CKV_AWS_161 IAM autentication is currently not in scope 
}

resource "aws_db_parameter_group" "this" {
  name_prefix = var.identifier_prefix
  family      = var.db_parameter_group_family

  dynamic "parameter" {
    for_each = local.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_db_subnet_group" "this" {
  name_prefix = var.identifier_prefix
  subnet_ids  = var.db_subnet_ids

  tags = var.tags
}

resource "aws_iam_role" "this" {
  count = var.monitoring_interval > 0 ? 1 : 0
  
  name_prefix =  "${var.identifier_prefix}-m-role"
  description =  "Role for extended momitoring for RDS Database ${var.identifier_prefix}..."
  assume_role_policy = data.aws_iam_policy_document.this.json
  tags = var.tags
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.monitoring_interval > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role = aws_iam_role.this.*.name[0]
}