aws docdb create-db-cluster \
    --db-cluster-identifier my-docdb-cluster \
    --engine docdb \
    --master-username myuser \
    --master-user-password MyStrongPwd123! \
    --vpc-security-group-ids sg-0123456789abcdef0 \
    --region us-east-1

aws docdb create-db-instance \
    --db-instance-identifier my-docdb-instance-1 \
    --db-cluster-identifier my-docdb-cluster \
    --engine docdb \
    --db-instance-class db.r5.large \
    --region us-east-1
