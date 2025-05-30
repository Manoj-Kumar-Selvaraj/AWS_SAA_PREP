# AWS_SAA_PREP
## AWS DEVELOPER ASSOCIATE PREP

# SECURITY

    -If the question mentions DDoS → pick Shield

    -If it talks about filtering HTTP requests, rules, SQL injection, IP blocking → pick WAF

Awesome — you're in the zone now! ⚡ Let's rapidly cover key **comparison-style AWS topics** that show up a lot in the **Developer Associate** exam.

---

## 🪣 S3 vs EBS vs EFS

| Feature         | **S3**                      | **EBS**               | **EFS**                     |
| --------------- | --------------------------- | --------------------- | --------------------------- |
| **Type**        | Object storage              | Block storage         | File storage                |
| **Access**      | HTTP-based (REST API)       | Attached to 1 EC2     | Shared across multiple EC2s |
| **Use Case**    | Store images, backups, logs | Store OS or DB on EC2 | Share files across EC2      |
| **Durability**  | 99.999999999% (11 9’s)      | High                  | High                        |
| **Scalability** | Auto                        | Manual                | Auto                        |
| **Mountable?**  | ❌ No                        | ✅ Yes (to 1 EC2)      | ✅ Yes (multi-EC2)           |

---

## 🔄 SNS vs SQS

| Feature               | **SNS (Simple Notification Service)**      | **SQS (Simple Queue Service)**         |
| --------------------- | ------------------------------------------ | -------------------------------------- |
| **Type**              | Pub/Sub (Fan-out)                          | Message Queue (Point-to-Point)         |
| **Delivery**          | Push                                       | Pull                                   |
| **Target**            | Many subscribers                           | One consumer per message               |
| **Use Case**          | Send alerts, fan-out to Lambda, SQS, email | Decouple microservices, buffer jobs    |
| **Message Retention** | Short (no persistence)                     | Up to 14 days                          |
| **Ordering?**         | No guarantee                               | FIFO queues support it (with dedup ID) |

---

## 🌐 API Gateway vs ALB (Application Load Balancer)

| Feature         | **API Gateway**                     | **ALB**                             |
| --------------- | ----------------------------------- | ----------------------------------- |
| **Purpose**     | Manage APIs (REST/HTTP/WebSocket)   | Distribute HTTP/HTTPS traffic       |
| **Best for**    | Serverless apps (e.g., with Lambda) | Traditional apps (EC2, ECS, etc.)   |
| **Supports**    | Auth, throttling, caching           | Path-based routing                  |
| **Cost**        | Per request                         | Per hour + data                     |
| **Integration** | Lambda, HTTP endpoints              | EC2, ECS, Lambda (via target group) |

---

## 🛑 IAM Role vs IAM Policy

| Feature               | **IAM Role**                        | **IAM Policy**                    |
| --------------------- | ----------------------------------- | --------------------------------- |
| **What is it?**       | Temporary identity to assume        | JSON doc that defines permissions |
| **Use Case**          | EC2/Lambda assumes it to access AWS | Attach to user/role/group         |
| **Temporary Access?** | ✅ Yes                               | ❌ No                              |
| **Attached to?**      | EC2, Lambda, users, services        | Users, groups, or roles           |

---

## 🧠 Lambda vs EC2

| Feature          | **Lambda**                  | **EC2**                         |
| ---------------- | --------------------------- | ------------------------------- |
| **Provisioning** | Fully managed               | You manage instance             |
| **Billing**      | Per invocation (ms)         | Per hour/second                 |
| **Startup Time** | Milliseconds                | Minutes                         |
| **Scaling**      | Auto                        | Manual unless using ASG         |
| **Use Case**     | Short tasks, APIs, triggers | Full control, long-running apps |

---

## ⚠️ CloudWatch vs CloudTrail

| Feature              | **CloudWatch**                        | **CloudTrail**                 |
| -------------------- | ------------------------------------- | ------------------------------ |
| **What it monitors** | Performance metrics, logs, alarms     | API calls and user activity    |
| **Level**            | Resource-level                        | Account-level                  |
| **Use Case**         | Alert on CPU > 80%, log Lambda output | Audit who deleted an S3 bucket |
| **Granularity**      | Real-time data                        | Historical event tracking      |

---
 
 Perfect — let’s laser-focus on **Security**, which is a major domain in the **AWS Developer Associate** exam (DVA-C02). It shows up in **nearly every other question**, either directly or as part of the scenario.

---

# 🔐 SECURITY — Exam-Critical Topics (Organized by Subdomain)

---
| **Rate-based Rules** | WAF can block IPs doing too many requests | Common in API Gateway questions                  |

---
## ✅ 6. **Secrets Management**

| Concept                 | Summary                                                                 | Exam Tips                                                          |
| ----------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **Secrets Manager**     | Manages credentials, rotates automatically                              | For DB creds, API keys                                             |
| **SSM Parameter Store** | Key-value store for config/secrets                                      | Supports encryption with KMS                                       |
| **Comparison**          | Secrets Manager: auto-rotation, more secure<br>SSM: cheaper, more basic | Use Secrets Manager when rotating secrets or when asked explicitly |

---

## ✅ 7. **CloudTrail & Monitoring**

| Concept             | Summary                                | Exam Tips                         |
| ------------------- | -------------------------------------- | --------------------------------- |
| **CloudTrail**      | Logs AWS API calls for auditing        | Use to find who did what and when |
| **EventBridge**     | React to events like IAM role creation | Use for auto-remediation          |
| **CloudWatch Logs** | Stores logs from Lambda, EC2, etc.     | Check for permissions and alarms  |

---

Great! These two are super important and often **confuse** people in the exam. Let’s break them down with clear visuals and analogies.

---

## 🔐 Envelope Encryption (used across AWS)

### 🧠 Definition:

**Envelope encryption** means:

* You **don’t encrypt the raw data** with your master key.
* Instead, you:

  1. Generate a **Data Encryption Key (DEK)**.
  2. Encrypt the data with the **DEK**.
  3. Encrypt the **DEK** using your **KMS Customer Master Key (CMK)**.

---

### 🧱 Why use it?

* It's **faster**: encrypting large files directly with KMS is slow.
* It's **scalable**: reuse DEK for large data, encrypt the DEK once with KMS.
* It's **secure**: data is encrypted using a fresh DEK, and the DEK is protected using your KMS CMK.

---

### 📦 Example (S3):

Let’s say you upload a file to S3 with SSE-KMS:

* S3 generates a **data key (DEK)**.
* Encrypts your file using that key.
* Then calls **KMS** to encrypt the DEK using your CMK.
* Stores:

  * The **encrypted data**
  * The **encrypted DEK** alongside it

When someone downloads the file:

* S3 decrypts the **DEK** using KMS
* Then uses the decrypted DEK to decrypt the file

---

### ✅ Envelope Encryption =

> “Encrypt the key, not the data directly”

---

## 🔐 KMS Key Policy (very exam-relevant)

### 🧠 What is it?

* A **resource-based policy** that controls who can **use or manage a KMS key (CMK)**.
* Stored **inside the KMS key itself**.
* Separate from IAM policies (identity-based).

---

### 🛑 Mistake trap in the exam:

Even if IAM says “Allow use of KMS”, if the **KMS key policy doesn't allow it**, the request will fail.

---

### 👇 2 Types of Access to CMKs:

| Access Type                | Example                                       |
| -------------------------- | --------------------------------------------- |
| **Use permissions**        | Encrypt, decrypt, generate data key           |
| **Management permissions** | Delete key, update policy, enable/disable key |

---

### 📄 Example Key Policy:

```json
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "AllowRootAccountFullAccess",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789012:root" },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
```

This says: "Allow full access to the root account."

---

### 🧪 Exam Clue:

If a user or Lambda can’t encrypt/decrypt even though IAM allows it →

> Check if the **KMS key policy** grants permission!

---

## ✅ Summary

| Topic                   | Key Point                                                                 |
| ----------------------- | ------------------------------------------------------------------------- |
| **Envelope Encryption** | Encrypt data using a generated key (DEK), then encrypt that key using KMS |
| **KMS Key Policy**      | Controls access at the key level — must allow usage even if IAM does      |

---

Excellent choice — **Amazon Cognito** is highly testable in the **AWS Developer Associate** exam, especially for mobile/web app scenarios. It's your go-to for **user authentication**, **authorization**, and **federated identities**.

---

## 🔐 Amazon Cognito — Developer-Focused Breakdown

---

### 📌 What Is Amazon Cognito?

> Cognito provides user sign-up, sign-in, and access control for web and mobile apps.

---

### 🧱 Two Main Components

| Component                                 | Purpose                                                 |
| ----------------------------------------- | ------------------------------------------------------- |
| **User Pools**                            | User directory for managing sign-up/sign-in             |
| **Identity Pools** (Federated Identities) | Grants temporary AWS credentials to access AWS services |

---

### 🔑 1. Cognito **User Pools**

Think of it like:
🔐 **Login System + User Management** (email/phone sign-up, passwords, MFA, etc.)

#### 💡 Key Features:

* Customizable **sign-up/sign-in UI**
* Built-in **MFA**, **password policies**
* Can integrate with:

  * Google, Facebook, Apple (social identity providers)
  * SAML / OIDC (enterprise identity)
* Returns **JWT tokens**: `id_token`, `access_token`, `refresh_token`

#### ✅ Exam Tip:

> Use **User Pool** when you need to **authenticate users** (e.g., login to your web/mobile app).

---

### 🔁 2. Cognito **Identity Pools**

Think of it like:
🎫 **Ticket system for temporary AWS access**

#### 💡 Purpose:

* Provides **temporary AWS credentials** via **STS**
* Authenticated via:

  * User Pools
  * Facebook/Google logins
  * IAM roles for anonymous or guest users

#### ✅ Exam Tip:

> Use **Identity Pool** when your app users need access to **AWS resources (e.g., S3, DynamoDB)** after logging in.

---

### 🧠 Example: Common Pattern in Exams

1. User signs in via **Cognito User Pool** → gets JWT token
2. Token sent to **Identity Pool**
3. Identity Pool returns **temporary credentials** via STS
4. User uses those to access S3, DynamoDB, etc.

---

### ⚙️ Developer Flow (Simplified)

```text
[ User ] → signs in with → [ Cognito User Pool ]
           ↓
[ JWT Token ] → sent to → [ Identity Pool ]
                      ↓
[ STS ] → returns temporary AWS credentials
                      ↓
[ Access AWS Services (S3, DynamoDB, etc.) ]
```

---

### 🔐 Security Features

| Feature             | Notes                                                              |
| ------------------- | ------------------------------------------------------------------ |
| MFA                 | Built-in for User Pools                                            |
| Token expiration    | Access tokens (1 hour), Refresh tokens (30 days)                   |
| IAM Roles           | Identity Pool assigns roles to authenticated/unauthenticated users |
| Fine-grained access | Use Cognito groups or role mapping for access control              |

---

## ✅ Summary Table

| Use Case                                | Use                                      |
| --------------------------------------- | ---------------------------------------- |
| User login/signup                       | Cognito **User Pool**                    |
| Social login (Facebook, Google)         | User Pool or Federated IdP               |
| Access S3 from web app after login      | **Identity Pool** (uses STS)             |
| MFA, email verification, password reset | Cognito **User Pool**                    |
| Guest access to S3                      | **Identity Pool** (unauthenticated role) |

---

### 🔍 Practice Question

> Your mobile app requires users to log in using email/password. After login, the app must allow users to upload images to S3. Which combination of Cognito components should you use?

A) User Pool only
B) Identity Pool only
C) User Pool + Identity Pool
D) IAM User per app user

Correct answer: **C** ✅

---

Awesome — **Secrets Manager vs SSM Parameter Store** is another **heavily tested** comparison in the AWS Developer Associate exam. Let’s break it down side-by-side.

---

## 🔐 Secrets Manager vs SSM Parameter Store

| Feature                   | **AWS Secrets Manager**                            | **SSM Parameter Store**                       |
| ------------------------- | -------------------------------------------------- | --------------------------------------------- |
| **Purpose**               | Store and manage **secrets** (DB creds, API keys)  | Store **configuration data** and **secrets**  |
| **Secret Rotation**       | ✅ **Built-in automatic rotation** via Lambda       | ❌ Manual rotation only                        |
| **Data Type**             | Secrets (key-value pairs)                          | Parameters (String, StringList, SecureString) |
| **Encryption**            | ✅ KMS                                              | ✅ KMS                                         |
| **Audit with CloudTrail** | ✅                                                  | ✅                                             |
| **Versioning**            | ✅ (built-in)                                       | ✅ (supports versions)                         |
| **Integration with RDS**  | ✅ Native (auto rotates RDS creds)                  | ❌ No built-in rotation                        |
| **Pricing**               | 💰 **Paid** (\~\$0.40/month/secret)                | ✅ **Free** for standard; advanced is paid     |
| **Max Size**              | 64 KB per secret                                   | 4 KB (standard), 8 KB (advanced)              |
| **API Access**            | `GetSecretValue`                                   | `GetParameter`                                |
| **Use case**              | Secrets that need **rotation** & **secure access** | Config values, feature flags, small secrets   |

---

### 🔑 Summary in Simple Terms:

* 🔐 **Secrets Manager** = For **sensitive secrets** (DB passwords, tokens) with auto-rotation needs
* ⚙️ **SSM Parameter Store** = For **general app configs** or **non-rotating secrets**

---

### 🎯 Exam Traps to Watch

| Scenario                                         | Use                                          |
| ------------------------------------------------ | -------------------------------------------- |
| You need to rotate RDS credentials automatically | ✅ **Secrets Manager**                        |
| Store an app’s config flags                      | ✅ **SSM Parameter Store**                    |
| Need to store a 2KB API key securely             | ✅ Either (Secrets Manager more feature-rich) |
| You want a **free** secret store                 | ✅ **SSM Parameter Store - Standard tier**    |

---

### 🔥 Practice Question

> You're building a Lambda function that needs to securely access an API key. The API key will rotate automatically every 30 days. What service should you use?

A) S3
B) IAM
C) SSM Parameter Store
D) Secrets Manager

✅ **Answer: D — Secrets Manager**

---
