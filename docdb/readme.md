 # **Amazon DocumentDB (with MongoDB compatibility) - Complete Notes**

---

## What is Amazon DocumentDB?

* **Amazon DocumentDB** is a fully managed, scalable, and highly available NoSQL document database service.
* Designed to be **compatible with MongoDB 3.6, 4.0, and 5.0 APIs**, so applications and tools built for MongoDB work with it.
* Supports **JSON-like document data models** (BSON format) for flexible and hierarchical data storage.
* Use cases: content management, catalogs, user profiles, mobile apps, IoT, real-time analytics.

---

## Core Concepts

### Cluster

* A **DocumentDB cluster** is a logical grouping of instances sharing the same data.
* Contains:

  * A **primary instance** (read/write)
  * Up to 15 **read replicas** (read-only) for scalability and high availability.
* The cluster endpoint abstracts the primary instance; you connect to the cluster endpoint for read/write.
* Read-only replicas have their own endpoints.

### Instances

* Instances are compute resources that serve the cluster data.
* Instance classes define CPU, memory, network capacity.
* Instances participate in replication within the cluster.
* Can scale horizontally by adding replicas.

### Storage

* Uses **durable, distributed SSD storage** across multiple Availability Zones (AZs).
* Storage automatically scales as data grows (no manual provisioning).
* Backups are continuous and automatic.

---

## Networking & Security

* Runs inside your **Amazon VPC** for network isolation.
* Requires **DB subnet groups**: subnets in your VPC for the cluster.
* Use **security groups** to control inbound/outbound traffic.
* Supports **encryption at rest** using AWS KMS.
* Supports **TLS** encryption for data in transit.
* Authentication via master username/password and optionally IAM integration.

---

## Backup and Restore

* Automatic backups enabled by default with a retention period up to 35 days.
* Point-in-time recovery available.
* Snapshots can be manually created and restored.
* Backups stored in S3 managed by AWS.

---

## High Availability and Failover

* Multi-AZ deployments with automatic failover to replicas.
* Failover time is typically under 30 seconds.
* Replicas handle read scaling and failover.

---

## Monitoring and Metrics

* CloudWatch metrics available for CPU, memory, disk I/O, connections, queries, etc.
* Events and logs can be streamed to CloudWatch Logs or AWS CloudTrail.

---

## Pricing

* Pay for instances (per hour), storage (per GB/month), and I/O operations.
* No upfront fees, pay as you go.
* Charges vary by instance class, storage type, backup retention, and data transfer.

---

## CLI Commands Overview

### Create Cluster

```bash
aws docdb create-db-cluster \
  --db-cluster-identifier my-docdb-cluster \
  --engine docdb \
  --master-username myuser \
  --master-user-password MyStrongPwd123! \
  --vpc-security-group-ids sg-0123456789abcdef0 \
  --region us-east-1
```

* Creates the cluster with master user and security group.
* Cluster is the logical data container.

### Create Instance in Cluster

```bash
aws docdb create-db-instance \
  --db-instance-identifier my-docdb-instance-1 \
  --db-cluster-identifier my-docdb-cluster \
  --engine docdb \
  --db-instance-class db.r5.large \
  --region us-east-1
```

* Creates an instance within the cluster for read/write access.
* Must specify the cluster identifier.

### Delete Instance and Cluster

* Delete instances before deleting the cluster.
* Use `aws docdb delete-db-instance` and `aws docdb delete-db-cluster`.

---

## Exam Tips

* Understand the **difference between cluster and instance**.
* Know that **DocumentDB uses replicas** for read scaling and availability.
* Know **DocumentDB is compatible with MongoDB APIs**, but it’s not a MongoDB server.
* Know **storage auto-scales**, no manual storage provisioning.
* Backup is automatic, but you can create manual snapshots.
* Multi-AZ failover is automatic for high availability.
* Understand **VPC networking, subnet groups, and security groups** for DocumentDB.
* Know key **CLI commands** to create/delete clusters and instances.

---

### What is a **Cluster** in Amazon DocumentDB?

A **cluster** is basically a group of one or more DocumentDB instances (servers) that work together to provide:

* **High availability:** If one instance fails, others keep the database up and running.
* **Fault tolerance:** Data is replicated across multiple instances.
* **Scaling:** You can add more instances (read replicas) to handle more read traffic without affecting writes.
* **Management:** The cluster manages backups, failovers, and replication automatically.

---

### Why is a Cluster Needed in DocumentDB?

* **Durability & Availability:** DocumentDB stores your data in a cluster to protect it from hardware failure or outages.
* **Replication:** By default, data is automatically replicated across multiple availability zones for resilience.
* **Scaling:** You can have a primary instance that handles writes and multiple read replicas for read queries to improve performance.
* **Maintenance:** Amazon DocumentDB applies updates and backups to the cluster as a whole without downtime.

---

### Summary in simple terms:

> A **cluster** is the core unit of DocumentDB—it’s like a “group” of database instances working together to keep your data safe, available, and scalable. You can’t have DocumentDB without a cluster.

---


