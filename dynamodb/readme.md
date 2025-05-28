---

# **Amazon DynamoDB – Key Concepts & Notes**

---

## What is DynamoDB?

* Fully managed **NoSQL key-value and document database** service.
* Provides **single-digit millisecond latency** at any scale.
* Serverless – no need to manage infrastructure (no servers or instances).
* Designed for applications requiring **high throughput and low latency**.
* Automatically scales up/down throughput capacity based on traffic (with on-demand mode).

---

## Core Concepts

### Table

* Data is stored in **tables**.
* Each table has a **primary key**: can be either

  * **Partition key (hash key)** only — uniquely identifies an item.
  * **Partition key + sort key (range key)** — allows composite keys and efficient queries.
* Tables do not enforce a fixed schema for attributes beyond the primary key.

### Item

* Each **item** is like a row in relational DB.
* It is a set of key-value pairs (attributes).
* Items within a table can have different attributes (schema-less).

### Attributes

* Attributes are the data fields within an item.
* Types supported: String, Number, Binary, Boolean, Null, List, Map, Set (StringSet, NumberSet, BinarySet).

### Indexes

* **Global Secondary Index (GSI)** — allows querying on non-primary key attributes.
* **Local Secondary Index (LSI)** — alternate sort key for same partition key.

### Capacity Modes

* **Provisioned Mode**: Specify read and write capacity units (RCUs & WCUs).
* **On-Demand Mode**: Pay-per-request, no need to provision capacity.
* Can enable **auto scaling** with provisioned mode.

### Consistency Models

* **Eventually consistent reads** (default, faster).
* **Strongly consistent reads** (optional).

---

## Features

* **Serverless** — no infrastructure to manage.
* **Highly available and durable** — replicates data across multiple AZs automatically.
* Supports **ACID transactions**.
* Supports **streams** for change data capture.
* Integrates with **AWS Lambda** for triggers on data changes.
* Supports TTL (time to live) for automatic item expiry.
* Fine-grained access control with **IAM policies**.
* Encryption at rest and in transit.

---

## Basic DynamoDB CLI commands

### Create Table

```bash
aws dynamodb create-table \
    --table-name MyTable \
    --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=Timestamp,AttributeType=N \
    --key-schema AttributeName=UserId,KeyType=HASH AttributeName=Timestamp,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

### Put Item (Insert)

```bash
aws dynamodb put-item \
    --table-name MyTable \
    --item '{"UserId": {"S": "user123"}, "Timestamp": {"N": "1620231123"}, "Message": {"S": "Hello World"}}' \
    --region us-east-1
```

### Get Item (Query by primary key)

```bash
aws dynamodb get-item \
    --table-name MyTable \
    --key '{"UserId": {"S": "user123"}, "Timestamp": {"N": "1620231123"}}' \
    --region us-east-1
```

### Query (Using Partition key + sort key conditions)

```bash
aws dynamodb query \
    --table-name MyTable \
    --key-condition-expression "UserId = :uid and Timestamp > :ts" \
    --expression-attribute-values '{":uid": {"S": "user123"}, ":ts": {"N": "1620000000"}}' \
    --region us-east-1
```

### Delete Table

```bash
aws dynamodb delete-table --table-name MyTable --region us-east-1
```

---

## Exam Tips

* Know the difference between **DynamoDB and RDS** (NoSQL vs SQL, serverless vs managed instances).
* Understand **primary key types** and their importance.
* Be able to explain **indexes** (GSI and LSI) and when to use them.
* Know **provisioned vs on-demand capacity modes**.
* Remember DynamoDB integrates seamlessly with Lambda, API Gateway, and other AWS services.
* DynamoDB tables can scale automatically with on-demand mode.
* TTL is used for automatic deletion of expired data.
* DynamoDB Streams support event-driven architectures.

---

### ✅ `--key-schema`

This defines how your table’s primary key is structured.

```bash
--key-schema AttributeName=$PARTITION_KEY,KeyType=HASH AttributeName=$SORT_KEY,KeyType=RANGE
```

#### 📌 Meaning:

* `AttributeName=$PARTITION_KEY,KeyType=HASH`:
  This defines the **partition key** (also called the hash key).
  DynamoDB uses this key’s value to **determine the partition (physical storage)** where the item will be stored.

* `AttributeName=$SORT_KEY,KeyType=RANGE`:
  This defines the **sort key** (also called the range key).
  Multiple items can have the same partition key, and the sort key helps to **uniquely identify** each item within the partition.

#### ✅ Example:

If `UserID` is your partition key and `Email` is your sort key:

| UserID  | Email                                       | Name |
| ------- | ------------------------------------------- | ---- |
| user123 | [john@example.com](mailto:john@example.com) | John |
| user123 | [jane@example.com](mailto:jane@example.com) | Jane |

👉 This enables you to **query all emails for a given UserID**.

---

### ✅ `--stream-specification`

```bash
--stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES
```

#### 📌 Meaning:

* `StreamEnabled=true`:
  Enables **DynamoDB Streams**, which is like a change-data-capture (CDC) mechanism.

* `StreamViewType=NEW_AND_OLD_IMAGES`:
  Tells DynamoDB to record both the **before and after states** of any modified item in the stream.

#### 📤 Why Use This?

* Useful for triggering **AWS Lambda** when an item is inserted/updated/deleted.
* Can be used for **replication**, **audit logging**, **real-time analytics**, etc.

#### ✅ StreamViewType Options:

| Option               | What it Captures                                                                             |
| -------------------- | -------------------------------------------------------------------------------------------- |
| `KEYS_ONLY`          | Only partition & sort key                                                                    |
| `NEW_IMAGE`          | Only new state (after change)                                                                |
| `OLD_IMAGE`          | Only old state (before change)                                                               |
| `NEW_AND_OLD_IMAGES` | Both old and new versions (before and after update) ✅ Most useful for audit, comparison, etc |

---
## ✅ 1. **Global Secondary Index (GSI)**

* **Use case**: You want to query on attributes that are **not the primary key**.
* **Flexibility**: GSI **can use any attribute** as the partition key and sort key.
* **Storage**: GSI has **its own provisioned throughput** and storage.

### 🧪 Hands-on: Create a table and add GSI

```bash
aws dynamodb create-table \
  --table-name GSIExampleTable \
  --attribute-definitions \
      AttributeName=UserId,AttributeType=S \
      AttributeName=Email,AttributeType=S \
  --key-schema \
      AttributeName=UserId,KeyType=HASH \
  --global-secondary-indexes \
      "[
        {
          \"IndexName\": \"EmailIndex\",
          \"KeySchema\": [
            {\"AttributeName\": \"Email\", \"KeyType\": \"HASH\"}
          ],
          \"Projection\": {
            \"ProjectionType\": \"ALL\"
          },
          \"ProvisionedThroughput\": {
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
          }
        }
      ]" \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

You can now **query** using Email (which is not the main key).

---

## ✅ 2. **Local Secondary Index (LSI)**

* **Use case**: You want **alternate ways to sort items** with the same Partition Key.
* **Constraint**: LSI must use the **same partition key** as the table.
* **Limit**: Max 5 LSIs per table and must be created **during table creation only**.

### 🧪 Hands-on: Create table with LSI

```bash
aws dynamodb create-table \
  --table-name LSIExampleTable \
  --attribute-definitions \
      AttributeName=OrderId,AttributeType=S \
      AttributeName=CreatedAt,AttributeType=N \
      AttributeName=Price,AttributeType=N \
  --key-schema \
      AttributeName=OrderId,KeyType=HASH \
      AttributeName=CreatedAt,KeyType=RANGE \
  --local-secondary-indexes \
      "[
        {
          \"IndexName\": \"PriceIndex\",
          \"KeySchema\": [
            {\"AttributeName\": \"OrderId\", \"KeyType\": \"HASH\"},
            {\"AttributeName\": \"Price\", \"KeyType\": \"RANGE\"}
          ],
          \"Projection\": {
            \"ProjectionType\": \"ALL\"
          }
        }
      ]" \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Now you can sort the same `OrderId` by `CreatedAt` **or** by `Price`.

---

## ✅ Summary

| Index | Partition Key | Sort Key | Created after table?     | Use case                        |
| ----- | ------------- | -------- | ------------------------ | ------------------------------- |
| GSI   | Any attribute | Optional | ✅ Yes                    | Query by alternate attributes   |
| LSI   | Same as table | Required | ❌ No (create with table) | Sort same partition differently |

---



