## CLI COMMAND TO CREATE RDS

aws rds create-db-instance \
  --db-instance-identifier mydb-instance \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0.35 \
  --allocated-storage 20 \
  --master-username admin \
  --master-user-password MySecurePass123 \
  --db-name mydatabase \
  --vpc-security-group-ids sg-0123456789abcdef0 \
  --availability-zone us-east-1a \
  --backup-retention-period 7 \
  --no-multi-az \
  --publicly-accessible \
  --storage-type gp2 \
  --enable-iam-database-authentication \
  --auto-minor-version-upgrade \
  --tags Key=Environment,Value=Dev \
  --region us-east-1


| Flag                                   | Purpose                                                  |
| -------------------------------------- | -------------------------------------------------------- |
| `--db-instance-identifier`             | Unique name of the DB instance                           |
| `--db-instance-class`                  | Instance type (e.g. `db.t3.micro` is Free Tier eligible) |
| `--engine`                             | DB engine (`mysql`, `postgres`, etc.)                    |
| `--engine-version`                     | Specific version of the engine                           |
| `--allocated-storage`                  | Storage in GB (min 20 GB for Free Tier)                  |
| `--master-username`                    | DB admin username                                        |
| `--master-user-password`               | Admin password                                           |
| `--db-name`                            | Initial database name                                    |
| `--vpc-security-group-ids`             | Security group for DB network access                     |
| `--availability-zone`                  | Specific AZ (optional)                                   |
| `--backup-retention-period`            | Days to retain automated backups                         |
| `--no-multi-az`                        | Disable Multi-AZ (for Free Tier)                         |
| `--publicly-accessible`                | Makes DB accessible via public IP                        |
| `--storage-type`                       | `gp2`, `io1`, or `standard`                              |
| `--enable-iam-database-authentication` | Enables IAM authentication                               |
| `--auto-minor-version-upgrade`         | Automatically apply minor updates                        |
| `--tags`                               | Add tags for organization                                |
| `--region`                             | Region to deploy in                                      |
