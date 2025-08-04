# Module RDS

Creates RDS Instances and security groups for them, described in yaml files.

## Resources

`aws_security_group.this`
`aws_db_subnet_group.this`
`aws_db_instance.this`

## Examples

### `securityGroups.yaml` file

The example shows a security group configuration that allows inbound connections from two vpc subnets and instances associated with that security group, and allows outbound connections to instances with that security group, and denies all other outbound connections.

```yaml
example-db-sg:
  description: "An example of a security group description."
  ingress-rules: [
    {
      description: "Allow incoming connections to port 3306 from vpc subnets and itself.",
      port: 3306,
      protocol: "tcp",
      cidr_blocks: [ "10.0.101.0/24", "10.0.102.0/24" ],
      self: true,
    },
  ]
  egress-rules: [
    {
      description: "Deny all outgoing connections except itself.",
      port: 0,
      protocol: -1,
      cidr_blocks: [ "127.0.0.1/32" ],
      self: true,
    },
  ]
```

Explanation:

- `example-db-sg`: **required**, name of the security group.
- `description`: **optional**, short description of the security group or ingress/egress rules.
- `ingress-rules`: **optional**, tuple of objects describes rules for incoming connections.
Allows incoming connections to any port within the VPC by default.
- `egress-rules`: **optional**, tuple of objects describes rules for outgoing connections.
Allows outgoing traffic to anywhere by default.
- `port`: **optional**, port for incoming/outgoing connections, default: All (0).
- `protocol`: **optional**, inbound/outbound traffic protocol, default: All (-1).
- `cidr_blocks`: **optional**, list of CIDR blocks to/from which connections are allowed.
Uses `var.vpc_cidr_block` to allow inbound connections only from the VPC for ingress rules and uses 0.0.0.0/0 to allow outbound connections to anywhere for egress rules by default.
- `self`: **optional**, Determines whether connections are allowed for this group itself, default: false.

### `databases.yaml` file

```yaml
example-db:
  apply_immediately: true
  allow_major_version_upgrade: true
  multi_az: false
  skip_final_snapshot: true
  security_group_name: "example-db-sg"
  instance_class: "db.t4g.small"
  allocated_storage: 16
  max_allocated_storage: 32
  engine: "mysql"
  engine_version: "8"
```

Explanation:

- `example-db`: **required**, database identifier.
Also used to create a subnet group with `${db_identifier}-subnets` name and in name the final snapshot - `${db_identifier}-final-snapshot`.
- `apply_immediately`: **optional**, apply the changes immediately, default: false.
- `allow_major_version_upgrade`: **optional**, allow major version database upgrades.
This parameter must be true to be able to upgrade to a new major version, default: false.
- `multi_az`: **optional**, use Multi-AZ deployment, default: true.
- `skip_final_snapshot`: **optional**, allow to delete the database without creating a final snapshot, default: false.
- `security_group_name`: **required**, name of the security group. Must match the name specified in security Groups.yaml.
- `instance_class`: **required**, type of database instances.
- `allocated_storage`: **optional**, allocated storage, default: 32Gb.
- `max_allocated_storage`: **optional**, maximum storage size, default: 64Gb.
- `engine`: **required**, database engine. [AWS Docs](https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html)
- `engine_version`: **required**, database engine version. [AWS Docs](https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html)
