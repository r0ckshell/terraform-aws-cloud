resource "aws_security_group" "this" {
  for_each = var.security_groups # at least one security group is required

  vpc_id      = var.vpc_id
  name        = each.key
  description = try(each.value.description, "")

  dynamic "ingress" {
    for_each = try(each.value.ingress-rules, [{}])
    content {
      description = try("${ingress.value.description}", "Allow incoming connections to any port within the VPC.")
      from_port   = try("${ingress.value.port}", 0)
      to_port     = try("${ingress.value.port}", 0)
      protocol    = try("${ingress.value.protocol}", -1)
      cidr_blocks = try("${ingress.value.cidr_blocks}", [var.vpc_cidr_block])
      self        = try("${ingress.value.self}", false)
    }
  }

  dynamic "egress" {
    for_each = try(each.value.egress-rules, [{}])
    content {
      description = try("${egress.value.description}", "Allow outgoing traffic to anywhere.")
      from_port   = try("${egress.value.port}", 0)
      to_port     = try("${egress.value.port}", 0)
      protocol    = try("${egress.value.protocol}", -1)
      cidr_blocks = try("${egress.value.cidr_blocks}", ["0.0.0.0/0"])
      self        = try("${egress.value.self}", false)
    }
  }

  tags = merge(local.tags, { Name = "${each.key}" })
}

resource "aws_db_subnet_group" "this" {
  for_each = var.databases

  name       = "${each.key}-subnets"
  subnet_ids = var.subnet_ids

  tags = local.tags
}

resource "aws_db_instance" "this" {
  for_each = var.databases

  apply_immediately           = try(each.value.apply_immediately, false)
  allow_major_version_upgrade = try(each.value.allow_major_version_upgrade, false)

  multi_az = try(each.value.multi_az, true)

  ## Performance Insights
  ##
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  ## Final snapshot
  ##
  skip_final_snapshot       = try(each.value.skip_final_snapshot, false)
  final_snapshot_identifier = "${each.key}-final-snapshot"

  ## Backup
  ##
  backup_retention_period = 7
  copy_tags_to_snapshot   = true

  ## VPC
  ##
  db_subnet_group_name   = aws_db_subnet_group.this[each.key].name
  vpc_security_group_ids = [aws_security_group.this[each.value.security_group_name].id]

  ## Instance
  ##
  identifier            = each.key
  instance_class        = each.value.instance_class
  allocated_storage     = try(each.value.allocated_storage, 32)
  max_allocated_storage = try(each.value.max_allocated_storage, 64)
  storage_encrypted     = true

  ## Database
  ##
  engine                      = each.value.engine
  engine_version              = each.value.engine_version
  username                    = "root"
  manage_master_user_password = true

  tags = local.tags

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}
