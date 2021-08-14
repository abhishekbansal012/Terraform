variable "identifier_prefix" {
    description = "Creates a unique identifier with the specified prefix"
}

variable "port" {
  description = "Specifies the port that the DB instance listens on"
  default = 5432
}

variable "allocated_storage" {
    type = number
    description = "Allocated storage in GB"
    default = 20
}

variable "max_allocated_storage" {
    type = number
    description = "Can be used to automatically scale the storage"
    default = null
}

variable "storage_type" {
    description = "Storage Type gp2/io1"
    default = "gp2"
}

variable "iops" {
    type = number
    description = "Provisioned IOPS for type io1"
    default = 1000
}

variable "instance_class" {
    description = "Instance Type of RDS instance"
    default = "db.t3.micro"
}

variable "engine_version" {
    description = "The engine version to use"
    default = "12"
}

variable "allow_major_version_upgrade" {
    type = bool
    default = false
}

variable "auto_minor_version_upgrade" {
    type = bool
    default = true
}

variable "name" {
  description = "RDS DB name."
}

variable "username" {
  description = "RDS DB user name."
}

variable "password" {
    description = "RDS DB password"
    default = ""
}

variable "backup_retention_period" {
  description = "Days to retain backups"
  default = 7
}

variable "backup_window" {
  description = "RDS backup window in UTC."
  default     = "22:00-23:30"
}
variable "maintenance_window" {
  description = "RDS maintenance window in ddd:hh24:mi-ddd:hh24:mi"
  default     = "Mon:00:00-Mon:03:00"
}
variable "multi_az" {
  description = "RDS multi-az HA feature."
  type        = bool
  default     = true
}
variable final_snapshot_identifier {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  default = null
}

variable "skip_final_snapshot" {
  description = "Create a final snapshot before destroying."
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
  description = "Set of log types to enable for exporting to CloudWatch logs"
  default = ["postgresql", "upgrade"]
}

variable "monitoring_interval" {
  description = "The interval in seconds to collect metrics"
  default = 60
}

variable "secretmanager_secret_arn" {
    type = string
    description = "Secretmanager Resource Name to store the DB password secure"
}

variable "security_group_ids" {
  type = list(string)
  description = "Security Group IDs"
}

variable "db_subnet_ids" {
  type = list(string)
  description = "Subnet IDS for the database" 
}

variable "db_parameter_group_family" {
  description = "Name of the DB Group Family"
  default = "postgres12"
}
variable "parameters" {
  type = list(map(string))
  description = "A list of DB paramater maps to apply"
  default = []
}

variable "deletion_protection" {
  type = bool
  description = "The database can't be deleted when this value is set to true"
}

variable "delete_automated_backups" {
description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
}