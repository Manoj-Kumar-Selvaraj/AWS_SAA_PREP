## ✅ What is Amazon ElastiCache?

**ElastiCache** is a fully managed **in-memory caching service** for real-time applications. It supports two engines:

| Engine        | Use Case                                         |
| ------------- | ------------------------------------------------ |
| **Redis**     | Advanced features: pub/sub, streams, persistence |
| **Memcached** | Simple caching, multi-threaded, no persistence   |

You typically use ElastiCache to **reduce database load**, **improve app latency**, and **store session data or frequently accessed data**.

---

## ✅ Key Concepts

| Term                          | Meaning                                            |
| ----------------------------- | -------------------------------------------------- |
| **Node**                      | A single cache server.                             |
| **Cluster (Memcached)**       | Collection of nodes (horizontal scaling).          |
| **Replication group (Redis)** | Primary + replicas + failover (high availability). |
| **Subnet group**              | Subnets in your VPC to launch ElastiCache nodes.   |
| **Parameter group**           | Like RDS, controls engine-level parameters.        |

---

## ✅ When to Use Redis vs Memcached?

| Feature                | Redis      | Memcached |
| ---------------------- | ---------- | --------- |
| Data Persistence       | ✅ Yes      | ❌ No      |
| Replication & Failover | ✅ Yes      | ❌ No      |
| Pub/Sub messaging      | ✅ Yes      | ❌ No      |
| Cluster Mode           | ✅ Optional | ✅ Always  |
| TLS Support            | ✅ Yes      | ❌ No      |

---

## 🛠️ Hands-On: Setup Redis Cluster (Free Tier Compatible)

### 1. Create a **Subnet Group** (required before creating cache)

```bash
aws elasticache create-cache-subnet-group \
  --cache-subnet-group-name my-cache-subnet-group \
  --cache-subnet-group-description "My cache subnet group" \
  --subnet-ids subnet-abc123 subnet-def456
```

> Replace with your actual subnet IDs (must be in **same AZ** for Free Tier).

---

### 2. Create a **Redis Cluster**

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id my-redis-cluster \
  --engine redis \
  --cache-node-type cache.t3.micro \
  --num-cache-nodes 1 \
  --cache-subnet-group-name my-cache-subnet-group \
  --security-group-ids sg-0123456789abcdef0 \
  --region us-east-1
```

✅ Free Tier allows: `cache.t2.micro` or `cache.t3.micro` with **1 node only**.

---

## 🧪 How to Connect?

* You'll need a **Linux EC2 instance** in the same VPC/subnet to **telnet** or use Redis CLI:

```bash
sudo yum install -y gcc jemalloc-devel tcl
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
make
src/redis-cli -h <redis-endpoint> ping
```

If successful, it will return:

```bash
PONG
```

---

## ✅ Common ElastiCache Use Cases

| Use Case                            | How ElastiCache Helps                   |
| ----------------------------------- | --------------------------------------- |
| Session storage                     | Store user sessions for web apps        |
| Query result caching                | Reduce RDS or DynamoDB query load       |
| Leaderboards, counters              | In-memory operations with Redis         |
| Pub/Sub messaging for microservices | Use Redis Streams or Pub/Sub model      |
| Real-time analytics                 | Fast access to frequently changing data |

---

## ❗ Limitations

* Not accessible from **outside VPC** (must use EC2/Bastion host).
* No built-in data encryption at rest for Memcached.
* No backup/restore for Memcached (only Redis).

---

