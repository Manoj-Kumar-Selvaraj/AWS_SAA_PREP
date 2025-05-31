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
-App Mest - Easily monitor and control micro services

- SSM - Choose if no key rotation

- Secret Manger - Choose if key rotation should be automatic

Absolutely! Here's a **clean and quick revision table** with **important AWS Auto Scaling & CloudWatch metrics** — tailored for the **Developer Associate exam**.

---

### ✅ **Auto Scaling & Metrics — Exam Revision Table**

| **Metric**                  | **Used For**                         | **Scaling Type**       | **Notes / Example**                                           |
| --------------------------- | ------------------------------------ | ---------------------- | ------------------------------------------------------------- |
| `CPUUtilization`            | CPU usage of EC2 instances           | Target Tracking / Step | Most common metric; e.g., keep CPU around 60%                 |
| `RequestCountPerTarget`     | Requests per EC2 behind ALB          | Target Tracking / Step | Scale when traffic hits threshold; ALB only                   |
| `NetworkIn`                 | Incoming data (bytes)                | Target Tracking / Step | For data-heavy applications (e.g., logs, uploads)             |
| `NetworkOut`                | Outgoing data (bytes)                | Target Tracking / Step | For services pushing data (e.g., media servers)               |
| `GroupDesiredCapacity`      | Desired # of EC2 in ASG              | Monitoring only        | Helps check expected number of running instances              |
| `GroupInServiceInstances`   | Healthy EC2s in service              | Monitoring only        | Should equal desired capacity under normal conditions         |
| `GroupPendingInstances`     | EC2s being launched                  | Monitoring only        | Useful to monitor scaling events in progress                  |
| `GroupTerminatingInstances` | EC2s being terminated                | Monitoring only        | Can indicate scale-in activity                                |
| `GroupTotalInstances`       | Total instances in ASG (any state)   | Monitoring only        | Helps audit full ASG size including starting/terminating ones |
| `ALBRequestCountPerTarget`  | ALB-level per-instance request count | Target Tracking / Step | Alternate name in some consoles/graphs                        |
| `ScheduledActionsExecuted`  | Number of scheduled scaling actions  | Scheduled Scaling      | Useful to verify cron-based scaling worked                    |

---
 `NetworkIn` --   The number of bytes received by a specific EC2 instance's network interface 
 
---

# 📊 AWS Metrics — The Ultimate Guide for Exam Prep

---

## 1️⃣ **CloudWatch Metrics: Overview**

* AWS services publish **metrics** (time-series data points).
* Metrics are organized into **namespaces** (e.g., `AWS/EC2`, `AWS/AutoScaling`, `AWS/ApplicationELB`).
* Each metric has **dimensions** (like InstanceId, AutoScalingGroupName).
* Metrics are stored as **data points** with timestamps, values, and units.

---

## 2️⃣ **Key Metrics for Auto Scaling (AWS/EC2 & AWS/AutoScaling)**

| Metric Name                   | Namespace       | Description                                         | Use in Exam Context                      |
| ----------------------------- | --------------- | --------------------------------------------------- | ---------------------------------------- |
| **CPUUtilization**            | AWS/EC2         | Percentage CPU usage of instance                    | Common trigger for scale-out/in          |
| **NetworkIn / NetworkOut**    | AWS/EC2         | Bytes received/sent by the instance                 | Use for scaling based on network traffic |
| **StatusCheckFailed**         | AWS/EC2         | Indicates if EC2 status checks failed (0=ok,1=fail) | Used to detect unhealthy instances       |
| **GroupInServiceInstances**   | AWS/AutoScaling | Number of instances currently running in ASG        | Used to monitor desired capacity         |
| **GroupPendingInstances**     | AWS/AutoScaling | Instances waiting to launch                         | Used to check if scaling is progressing  |
| **GroupTerminatingInstances** | AWS/AutoScaling | Instances currently terminating                     | Track scale-in progress                  |
| **GroupDesiredCapacity**      | AWS/AutoScaling | Desired number of instances in ASG                  | Key for checking target capacity         |

---

## 3️⃣ **Elastic Load Balancer Metrics**

| Metric Name                      | Namespace          | Description                               | Exam Focus                               |
| -------------------------------- | ------------------ | ----------------------------------------- | ---------------------------------------- |
| **HealthyHostCount**             | AWS/ApplicationELB | Number of healthy targets in target group | Use to verify instance health behind ELB |
| **UnHealthyHostCount**           | AWS/ApplicationELB | Number of unhealthy targets               | Identify target failures                 |
| **RequestCount**                 | AWS/ApplicationELB | Number of requests processed              | Understand traffic load                  |
| **HTTPCode\_Target\_5XX\_Count** | AWS/ApplicationELB | Count of 5xx errors from targets          | Used for troubleshooting backend errors  |
| **TargetResponseTime**           | AWS/ApplicationELB | Average response time of targets          | For performance tuning                   |

---

## 4️⃣ **CloudWatch Metric Math**

* Allows you to **combine multiple metrics** into one expression.
* Example: Calculate **average CPU across all instances in ASG**.
* Exam scenarios might test your ability to create composite alarms based on metric math.

---

## 5️⃣ **Custom Metrics**

* You can **publish your own metrics** (e.g., application-level metrics) to CloudWatch.
* Common exam example: monitoring queue length, custom error counts, etc.
* Use **AWS CLI or SDK** to put custom metrics.

Example CLI command to put a custom metric:

```bash
aws cloudwatch put-metric-data --namespace "MyApp" --metric-name "ProcessingLatency" --value 150 --unit Milliseconds
```

---

## 6️⃣ **CloudWatch Alarms**

* Alarms monitor metrics and trigger actions (like scale-out policies, SNS notifications).
* Alarm states: `OK`, `ALARM`, `INSUFFICIENT_DATA`.
* Exam Tip: Know how to configure alarms for scaling triggers using CPU, Network, or custom metrics.

---

## 7️⃣ **Important Dimensions**

| Service      | Important Dimensions                            |
| ------------ | ----------------------------------------------- |
| EC2          | InstanceId                                      |
| Auto Scaling | AutoScalingGroupName                            |
| ELB          | LoadBalancerName, AvailabilityZone, TargetGroup |
| RDS          | DBInstanceIdentifier                            |

---

## 8️⃣ **Exam Tip: Metrics Retention**

* CloudWatch metrics are stored at different resolutions:

  * **1-minute granularity** for 15 days (standard metrics)
  * **1-second granularity** for 3 hours (detailed monitoring)
* Know that **detailed monitoring costs extra** but provides finer granularity for alarms.

---

# ⚡ **Summary Table**

| Use Case                    | Metric(s) To Monitor                           | Notes                                     |
| --------------------------- | ---------------------------------------------- | ----------------------------------------- |
| Auto Scaling trigger        | CPUUtilization, NetworkIn/Out                  | Use CloudWatch alarms to automate scaling |
| Instance health check       | StatusCheckFailed                              | Replace or terminate unhealthy instances  |
| ELB target health           | HealthyHostCount, UnHealthyHostCount           | Troubleshoot backend failures             |
| Application latency         | Custom metrics (e.g., ProcessingLatency)       | Publish with PutMetricData                |
| Scaling progress monitoring | GroupInServiceInstances, GroupPendingInstances | To verify scaling actions                 |

---

### ⚡ **Scaling Types Summary Table**

| **Scaling Type**   | **Based On Metric?** | **When to Use**                                     |
| ------------------ | -------------------- | --------------------------------------------------- |
| Target Tracking    | ✅ Yes                | Maintain metric at a target value (e.g. CPU at 50%) |
| Step Scaling       | ✅ Yes                | Scale in steps based on metric thresholds           |
| Scheduled Scaling  | ❌ No                 | Fixed-time scaling (e.g., 9AM weekdays)             |
| Predictive Scaling | ✅ (forecast-based)   | Advanced use cases (less common in exam)            |

---


---

## 🔥 Advanced Topics: **Auto Scaling, Launch Templates, Load Balancers** (DA-C02)

### 🔷 1. **Launch Template vs Launch Configuration**

| Feature                       | **Launch Template** | **Launch Configuration** |
| ----------------------------- | ------------------- | ------------------------ |
| Current AWS Recommendation    | ✅ Yes               | ❌ Deprecated             |
| Support for multiple versions | ✅ Yes (v1, v2...)   | ❌ No                     |
| Spot Instance support         | ✅ Yes               | ✅ Partial                |
| T2/T3 Unlimited support       | ✅ Yes               | ❌ No                     |
| Use with EC2 Auto Scaling     | ✅ Yes               | ✅ Yes                    |
| Tagging on launch             | ✅ Supported         | ❌ No                     |
| Mixed instance policies       | ✅ Required          | ❌ Not supported          |

🧠 **Exam Tip:** If a question gives you version numbers, or asks about mixed instances → the answer is **Launch Template**.

---

### 🔷 2. **Auto Scaling Advanced Concepts**

#### a. **Instance Refresh**

* Used to **replace existing instances** in ASG with **newer version** (e.g., new AMI or config).
* You can do this **without replacing the whole ASG**.

✅ Triggered when:

* Launch template is updated
* You manually call `StartInstanceRefresh`

🧠 **Exam Tip:** Look for keywords like *“rotate instances with latest AMI without downtime”* → **Instance Refresh**

---

#### b. **Warm Pools**

* Keeps instances in a **stopped** or **pre-initialized** state.
* **Faster scale-out** because EC2s don’t need full provisioning time.

🧠 **Exam Tip:** If a question mentions **“faster launch time”** or **“pre-initialized EC2s”**, the answer is **Warm Pool**.

---

#### c. **Lifecycle Hooks**

* Pause instance launch/terminate process to do custom logic (e.g., install agent).
* Use **SNS or SQS** to notify a Lambda or script.

🧠 **Example Exam Scenario:**

> “Before terminating EC2, backup data to S3” → Use **Lifecycle Hook**

---

#### d. **Mixed Instances Policy**

* Allows ASG to use **multiple instance types** and **purchase options** (On-Demand + Spot).
* You define **weights** (e.g., m5.large = 1, m5.xlarge = 2).

🧠 **Exam Tip:** If question asks for **cost-optimized scaling** with **instance diversity** → use **Mixed Instances Policy + Launch Template**

---

### 🔷 3. **Elastic Load Balancer (ELB) Exam-Level Concepts**

#### a. **Connection Draining / Deregistration Delay**

* When instance is removed from LB, **waits before closing connections**.
* Default is 300s. Configurable.

🧠 **Exam Tip:** Look for **graceful shutdown of in-flight requests**.

---

#### b. **Cross-Zone Load Balancing**

* Distributes traffic **evenly across AZs**.
* Enabled by default on **ALB**, **disabled by default** on **NLB**.

🧠 ALB always uses Cross-Zone Load Balancing.
🧠 NLB may need it **explicitly enabled**.

---

#### c. **ALB Listener Rules & Path-Based Routing**

* ALB supports:

  * **Path-based routing** (e.g., `/api/*` → target group 1)
  * **Host-based routing** (e.g., `admin.site.com`)

🧠 **Exam Tip:** “Route to different microservices based on path/host” → use **ALB**

---

#### d. **Target Groups**

| Component        | Detail                          |
| ---------------- | ------------------------------- |
| Used by          | ALB, NLB, ASG                   |
| Health Checks    | Done per target group           |
| Protocol Support | HTTP/HTTPS for ALB, TCP for NLB |
| Target Types     | `instance`, `ip`, or `lambda`   |

🧠 If question mentions **container IPs** (e.g., ECS tasks), target type should be **`ip`**

---

#### e. **Sticky Sessions (Session Affinity)**

* Enabled via **cookies** (ALB) or **source IP** (NLB).
* Keep user connected to same instance.

🧠 **Exam Tip:** Use sticky sessions only if **user state is not shared** across instances (e.g., non-distributed cache).

---

### ✅ Summary: **High-Yield Must-Know**

| Concept                | Keyword in Exam Question                        |
| ---------------------- | ----------------------------------------------- |
| Launch Template        | versioning, mixed instance types, spot support  |
| Lifecycle Hook         | install agent, backup before terminate          |
| Instance Refresh       | replace instances with new config               |
| Warm Pool              | fast launch, pre-initialized                    |
| Mixed Instances Policy | cost optimization, multiple types               |
| ALB Listener Rules     | route `/admin`, host `admin.app.com`            |
| Sticky Sessions        | same user → same instance                       |
| Target Group Types     | ECS IP, Lambda function                         |
| Cross-Zone LB          | balance across AZs, ALB/NLB config              |
| Deregistration Delay   | complete user requests before removing instance |

---

## 🧠 **ASG, Launch Template, and ELB - Deep Dive & Hidden Exam Nuggets**

---

### 🔹 **ASG Scaling Policies** — More Types

| **Policy Type**        | **Description**                                                            | **When to Use**                                   |
| ---------------------- | -------------------------------------------------------------------------- | ------------------------------------------------- |
| **Target Tracking**    | Keeps a **metric** (e.g., CPU) at a specific target (like thermostat).     | ✅ Default, easiest to configure                   |
| **Step Scaling**       | Scales **based on breach thresholds** — more control than Target Tracking. | ✅ Granular control (e.g., +1 for 60%, +2 for 80%) |
| **Simple Scaling**     | Waits for cooldown period after scaling.                                   | ❌ Outdated, **avoid** in real use                 |
| **Scheduled Scaling**  | Scales **at a specific time**.                                             | ✅ Predictable workload (e.g., 8 AM daily)         |
| **Predictive Scaling** | Uses **ML forecast** to scale **before** traffic spike.                    | ✅ Best for high-traffic known patterns            |

🧠 **Exam Tip**: They’ll give you a scenario like:

> “Scale up by 2 instances when CPU > 75% for 5 minutes”
> → **Step Scaling**

---

### 🔹 **Launch Template - Versions**

* You can **manually specify** which version to use in ASG.
* OR set it to **"latest"** or **"default"**.

🧠 **Exam Tip**:

> If a question says: *“Always use most recent template when ASG launches”* → answer is **launch template default = latest**.

---

### 🔹 **Cooldowns (important exam nuance)**

| Cooldown Type                | Meaning                                         |
| ---------------------------- | ----------------------------------------------- |
| **Default Cooldown**         | Pause between scale actions (default 300s).     |
| **Instance Cooldown**        | Overrides default, applies per instance launch. |
| **Target Tracking Cooldown** | Managed automatically — **don't set manually**. |

🧠 Exam sometimes tests which cooldowns apply for which scaling policies.

---

### 🔹 **Load Balancers & ASG Integration Nuances**

1. **ALB and ASG:**

   * Health checks go to the **Target Group**, **not EC2** directly.
   * EC2 marked **unhealthy → ASG replaces it**.

2. **Classic Load Balancer + ASG:**

   * Health check is **EC2-based**, not target-group based.
   * Old-school, mostly deprecated.

3. **NLB:**

   * Doesn’t do HTTP health checks — uses TCP health checks only.
   * Can be used for **very high-performance apps**.

---

### 🔹 **ASG Health Check Types**

| Type          | Description                           |
| ------------- | ------------------------------------- |
| **EC2**       | Checks EC2 status checks.             |
| **ELB**       | Uses health of instance from ALB/CLB  |
| **EC2 + ELB** | Use ELB health, fallback to EC2 check |

🧠 **If EC2 fails health check → ASG terminates & replaces it.**

---

### 🔹 **Sticky Sessions (Advanced Notes)**

| Type | Mechanism       | Notes                               |
| ---- | --------------- | ----------------------------------- |
| ALB  | Cookie-based    | `AWSALB` or custom cookie           |
| NLB  | Source IP-based | Stickiness by IP (not cookie-based) |

🧠 Use sticky sessions **only** when app has **stateful backend**.

---

### 🔹 **Load Balancer Listener Rules – Multi-Service Deployments**

For **ALB**:

```plaintext
/app1/*   → Target Group 1
/app2/*   → Target Group 2
```

🧠 Can also **prioritize rules** using **rule evaluation order**.

---

### 🔹 **ELB Advanced Exam Traps**

| Concept                | Common Exam Misunderstanding                   |
| ---------------------- | ---------------------------------------------- |
| Deregistration Delay   | Think **graceful shutdown**. Default is 300s.  |
| Cross-Zone LB          | ✅ Default **on ALB**, ❌ Default **off on NLB** |
| HTTP to HTTPS Redirect | Use ALB listener rules                         |
| ALB & Lambda           | ALB can directly invoke **Lambda** as a target |

---

### 🔹 **ELB Pricing Tip (AWS likes this)**

| LB Type | Billed For                        |
| ------- | --------------------------------- |
| ALB     | LCU (Request count + Bandwidth)   |
| NLB     | LCU (New connection/active flows) |
| CLB     | Hourly + GB                       |

🧠 “Which ELB is most cost-effective for high throughput TCP app?” → **NLB**

---

### 🔹 Realistic Exam Traps to Watch

| Question Hint                                     | Likely Answer                 |
| ------------------------------------------------- | ----------------------------- |
| “Need multiple versions of config for ASG”        | Launch Template               |
| “Predict scale based on recurring traffic”        | Predictive Scaling            |
| “Backup app data before termination”              | Lifecycle Hook + SNS + Lambda |
| “Cost-optimize across instance types”             | Mixed Instance Policy         |
| “Direct /api/\* and /admin/\* to diff containers” | ALB path-based routing        |
| “Ensure user always lands on same EC2 instance”   | Sticky Sessions               |
| “Scale out instantly with pre-initialized VMs”    | Warm Pool                     |

---

Great question! **Target Tracking** and **Step Scaling** are both Auto Scaling policy types in AWS, and they appear **frequently in the AWS Developer Associate exam**. Here’s a detailed comparison to help you understand how they work and when to use which.

---

## 🔍 **Target Tracking vs Step Scaling (in Detail)**

| Feature / Aspect             | **Target Tracking Scaling**                                   | **Step Scaling**                                     |
| ---------------------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| **Purpose**                  | Keep a metric (e.g., CPU) at a specific **target value**      | Scale based on **custom thresholds** and **steps**   |
| **Working Style**            | Like a thermostat – maintains the desired level               | Works like a manual scale plan (if metric > X, do Y) |
| **Example Use Case**         | Maintain average CPU at 50%                                   | Scale out by 1 if CPU > 60%, by 2 if > 80%           |
| **Configuration Simplicity** | ✅ Very simple                                                 | ❌ More complex – needs multiple steps                |
| **Requires Thresholds?**     | ❌ No need to define thresholds                                | ✅ You define thresholds and how much to scale        |
| **Cooldown Periods**         | Managed **automatically**                                     | You must **manage cooldowns manually**               |
| **Can Overshoot Target?**    | Yes, **can overshoot temporarily**, then scale in/out to fix  | Less likely to overshoot, but reacts more slowly     |
| **Supported Metrics**        | - CPUUtilization<br>- ALBRequestCountPerTarget<br>- Custom CW | Any **CloudWatch alarm** metric                      |
| **Use With Predictive?**     | ✅ Compatible with **Predictive Scaling**                      | ❌ Not compatible                                     |

---

## 🔧 **How They Work (Behind the Scenes)**

### 🎯 Target Tracking

**Goal**: Maintain a target metric value.

📌 Example:

```text
Target CPU = 50%
→ If CPU > 50% → scale out
→ If CPU < 50% → scale in
```

* AWS automatically adjusts based on the metric deviation.
* You don’t define step values or thresholds.
* Automatically includes **cooldown periods** to avoid over-scaling.

🧠 **Analogy**: Like a smart AC system trying to maintain 24°C.

---

### 📶 Step Scaling

**Goal**: Scale in/out **based on exact conditions and step sizes**.

📌 Example:

```text
If CPU > 60% → Add 1 instance
If CPU > 80% → Add 2 instances
If CPU < 40% → Remove 1 instance
```

* You create multiple **CloudWatch alarms**.
* Each alarm triggers a **step adjustment**.
* You manage **cooldowns** manually or via instance cooldowns.

🧠 **Analogy**: Like a person manually switching on/off fans depending on how hot it gets.

---

## 🧠 **Which to Use When?**

| Situation                                                | Use...                     |
| -------------------------------------------------------- | -------------------------- |
| Want simple config with consistent metric control        | ✅ **Target Tracking**      |
| App has variable load and you need precise scaling rules | ✅ **Step Scaling**         |
| You're OK with AWS auto-managing cooldowns               | ✅ **Target Tracking**      |
| You want full manual control over scaling thresholds     | ✅ **Step Scaling**         |
| Using predictive scaling                                 | ✅ **Target Tracking only** |

---

## 📌 **Real Exam-Style Scenarios**

1. **Q:** Your app should maintain average CPU at 50% without manual rules. What policy?

   * **A:** ✅ Target Tracking

2. **Q:** Your app should add 2 instances if CPU > 80% and 1 if CPU > 60%. What policy?

   * **A:** ✅ Step Scaling

3. **Q:** You want automatic scale-in and scale-out without writing CloudWatch alarms.

   * **A:** ✅ Target Tracking

---

Absolutely! Let’s deep dive into **EC2** with an exam-focused approach, covering essential concepts and advanced topics you must know for the AWS Developer Associate exam.

---

# 🚀 EC2 Deep Dive — AWS Developer Associate Exam Focus

---

## 1️⃣ EC2 Instance Types & Pricing

* **Instance types:** General purpose (t3, m5), Compute optimized (c5), Memory optimized (r5), Storage optimized (i3), GPU (p3).
* **Pricing models:**

  * **On-demand**: pay per hour/second, no upfront.
  * **Reserved instances (RI)**: upfront commitment, cheaper.
  * **Spot instances**: bid for spare capacity, cheapest but can be interrupted.
  * **Dedicated hosts**: physical server for compliance.

*Exam tip:* Know when to use each type — Spot for cost saving, RI for steady state, On-demand for flexibility.

---

## 2️⃣ EC2 Launch & Bootstrapping

* **Launch types:**

  * From AMI (custom or marketplace)
  * With Launch Templates or Launch Configurations (used by ASG)
* **User data:** Run scripts on instance boot (e.g., install packages, start services).
* **Cloud-init:** A tool for instance initialization.
* **Instance metadata:** Information about the instance (IP, ID, IAM role, etc.) accessible inside the instance via `http://169.254.169.254/latest/meta-data/`.

*Exam tip:* Know how to use user data for automation; metadata is useful for dynamic configs inside the instance.

---

## 3️⃣ EC2 Networking Essentials

* **ENI (Elastic Network Interface):** Network card attached to instance; supports multiple ENIs.
* **Public IP vs Elastic IP:** Public IP is dynamic; Elastic IP is static and can be remapped.
* **Security Groups:** Stateful firewall attached to ENI; controls inbound and outbound traffic.
* **NACLs (Network ACLs):** Stateless firewall on subnet level; both inbound and outbound must be allowed.
* **VPC/Subnet:** Instances run inside a VPC; subnet defines IP range.

*Exam tip:* Security groups are stateful, NACLs stateless — often tested.

---

## 4️⃣ EC2 Storage Options

* **EBS (Elastic Block Store):** Persistent block storage for EC2; can be General Purpose SSD (gp2/gp3), Provisioned IOPS SSD (io1/io2), Throughput Optimized HDD (st1), Cold HDD (sc1).
* **Instance Store:** Temporary local storage; data lost if instance stops.
* **EFS:** Managed network file system for multiple instances.

*Exam tip:* Know which storage survives instance stop/start (EBS does, instance store doesn’t).

---

## 5️⃣ Advanced EC2 Features

* **Placement groups:**

  * **Cluster:** Low latency, high bandwidth between instances.
  * **Spread:** Separate hardware for critical instances.
  * **Partition:** Divide instances into partitions for fault isolation.
* **Elastic Fabric Adapter (EFA):** For HPC workloads with low latency.
* **IAM Roles for EC2:** Assign permissions to instances without embedding credentials.

---

## 6️⃣ EC2 Monitoring & Troubleshooting

* **CloudWatch metrics:** CPUUtilization, StatusCheckFailed, DiskReadOps, NetworkIn/Out.
* **Status checks:**

  * **System status check:** AWS infrastructure issues.
  * **Instance status check:** OS or networking problems.
* **EC2 Serial Console:** Debug instances that fail to boot.
* **SSM Agent:** Manage instances without SSH.

---

## 7️⃣ EC2 Security Best Practices

* Use IAM roles instead of access keys on instance.
* Restrict security group rules to least privilege.
* Use encrypted EBS volumes.
* Enable CloudTrail to track API calls.
* Use Systems Manager for patch management and automation.

---

## 8️⃣ Exam Tips: EC2

* Know the differences between instance states: pending, running, stopping, stopped, terminated.
* Understand how Elastic IP behaves when instance stops/starts.
* Know how to create and use AMIs for instance cloning and backups.
* Understand the difference between Launch Templates and Launch Configurations (Templates are newer and support more features).
* Be familiar with how EC2 integrates with Auto Scaling and ELB.

---

Absolutely! Here are some **advanced EC2 topics** you should know for the AWS Developer Associate exam — beyond the basics, with a focus on what might come up or help you stand out:

---

# 🔥 Advanced EC2 Topics for AWS Developer Associate Exam

| Topic                                              | Description & Exam Relevance                                                                                                                                                                                |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Launch Templates vs Launch Configurations**      | Launch Templates support versioning, allow more features (like T2 unlimited, Elastic GPUs, Spot options), and are preferred over Launch Configurations. Know when to use which, and that ASGs can use both. |
| **EC2 Hibernate**                                  | Save instance RAM state to disk on stop, so instance resumes quickly. Useful for stateful apps. Know that Hibernate requires encrypted root volumes and is only for supported instance types.               |
| **Spot Instances with Capacity Rebalancing**       | Spot instances can be interrupted, but capacity rebalancing proactively helps maintain availability by launching replacement Spot instances early. Useful for fault-tolerant apps.                          |
| **Placement Groups Deep Dive**                     | Know the difference between Cluster, Spread, and Partition placement groups — their use cases and limits. E.g., Cluster for low latency HPC, Spread for critical fault tolerance.                           |
| **Elastic Network Interfaces (ENI) Attach/Detach** | ENIs can be detached and attached to other instances. Useful for failover scenarios or maintaining static IPs across instance replacements.                                                                 |
| **Dedicated Hosts and Dedicated Instances**        | Understand the difference: Dedicated hosts are physical servers reserved for you (for compliance), dedicated instances run on shared hardware but isolated from other tenants. Pricing and use cases.       |
| **Enhanced Networking**                            | Using Elastic Network Adapter (ENA) or Intel 82599 VF for higher bandwidth and lower latency network performance. Important for high throughput workloads.                                                  |
| **User Data and Cloud-init Advanced Use**          | Passing complex scripts or multi-line commands; use of MIME multi-part for combining shell scripts with cloud config YAML.                                                                                  |
| **Instance Metadata Service v2 (IMDSv2)**          | Newer, more secure method to fetch instance metadata, protects against SSRF attacks. Exam may ask how to enable or why to use IMDSv2.                                                                       |
| **EC2 Fleet and Spot Fleet**                       | Allows management of large numbers of Spot and On-Demand instances, balancing cost and capacity automatically. Useful for batch jobs or scalable workloads.                                                 |
| **EBS Optimization & Throughput**                  | Enabling EBS-optimized instances, which provide dedicated bandwidth to EBS volumes to avoid network contention.                                                                                             |
| **EC2 Auto Recovery**                              | Automatic recovery of impaired instances at hardware level. Know how to configure with CloudWatch alarms.                                                                                                   |
| **AMI Sharing & Encryption**                       | Sharing AMIs across accounts securely; creating encrypted AMIs; implications for security and compliance.                                                                                                   |
| **Instance Store Limitations**                     | Understand data loss scenarios with instance store volumes (stopping, terminating instances) and when to use vs EBS.                                                                                        |
| **EC2 Serial Console**                             | Use serial console to troubleshoot instances that don’t boot or have network issues, even without SSH access.                                                                                               |
| **Spot Instance Interruptions Handling**           | Use of CloudWatch Events or Spot interruption notices to gracefully handle Spot termination.                                                                                                                |
| **Elastic GPUs**                                   | Add GPU acceleration to instances that don’t natively support GPUs. Understand when to use for graphics-heavy apps.                                                                                         |

---

### Exam Tips:

* Be ready to choose correct instance type/features for a scenario (e.g., spot with capacity rebalancing vs regular spot).
* Know security implications and best practices around instance metadata.
* Understand when to use dedicated hosts for compliance vs other instance types.
* Understand how to automate recovery and troubleshooting.
* Remember, launch templates are more flexible and recommended over launch configurations.

---

************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
                                                               
                                                               # Elastic Beanstalk
                                                            
************************************************************************************************************************************************************************************************************************************************************************************************************************************************************



---

# 🚀 Elastic Beanstalk Deep Dive — Exam Essentials

---

## 1️⃣ What is Elastic Beanstalk?

* **Platform as a Service (PaaS)** that lets you deploy and manage applications easily.
* It is mainly used for web application.
* You just upload your code; EB handles provisioning EC2, load balancing, auto scaling, monitoring, and app health.
* Supports multiple platforms: Java, .NET, Node.js, Python, Ruby, Go, Docker, and more.

---

## 2️⃣ How Elastic Beanstalk Works

* You create an **application** → deploy a **version** → EB creates an **environment**.
* An environment consists of AWS resources (EC2, Auto Scaling Group, ELB, RDS if configured, S3, CloudWatch).
* EB manages infrastructure and deployment lifecycle.

---

## 3️⃣ Supported Deployment Methods

| Deployment Type                   | Description                                                    | Use Case                                      |
| --------------------------------- | -------------------------------------------------------------- | --------------------------------------------- |
| **All at once**                   | Deploys to all instances simultaneously (downtime).            | Fast deployments, small apps                  |
| **Rolling**                       | Deploys in batches, keeping some instances running.            | Minimize downtime but slower than all-at-once |
| **Rolling with additional batch** | Adds new instances, deploys, then removes old.                 | Minimize downtime and capacity impact         |
| **Immutable**                     | Deploys new instances in a separate group, then swaps over.    | Zero downtime and easy rollback               |
| **Blue/Green**                    | Create separate environment, switch traffic by swapping CNAME. | Safe deployments and rollback                 |

*Exam tip:* Know the difference and use cases of each deployment method.

---

---

### 🔵 Blue/Green Deployment

* **How it works:**
  You create a completely **separate environment** (green) with the new version while the old environment (blue) is still running. Once green is ready and tested, you swap the DNS/CNAME to redirect traffic to the green environment.

* **Pros:**

  * Near-zero downtime.
  * Easy rollback: just switch DNS back to blue.
  * No impact on running environment during deployment.

* **Cons:**

  * Requires double the resources temporarily (costly).
  * Longer deployment time due to environment provisioning.

* **Use case:**

  * When zero downtime and safe rollback are critical.
  * Production apps needing maximum availability.

---

### 🟣 Immutable Deployment

* **How it works:**
  EB launches a **parallel fleet** of new instances with the new version inside the **same environment** (uses a separate Auto Scaling group). Once these pass health checks, EB shifts traffic from old instances to new ones, then terminates the old instances.

* **Pros:**

  * Zero downtime.
  * Safer than in-place since new instances are built from scratch.
  * Rollback is straightforward: EB keeps old instances until new ones are healthy.

* **Cons:**

  * Still requires extra instances temporarily (cost/capacity).
  * Slightly slower than in-place.

* **Use case:**

  * When you want zero downtime but prefer not to swap environments.
  * Environments where environment URLs must remain consistent.

---

### 🔴 In-Place Deployment (All at Once / Rolling / Rolling with Additional Batch)

* **How it works:**

  * **All at Once:** Updates *all* instances simultaneously by stopping old versions and starting new ones.
  * **Rolling:** Updates instances in batches, a subset at a time, so some capacity remains serving.
  * **Rolling with Additional Batch:** Adds a new batch of instances to deploy the new version before terminating old batches, reducing downtime further.

* **Pros:**

  * Lower cost, no double environment or full parallel fleet.
  * Faster deployments (especially all at once).

* **Cons:**

  * Risk of downtime (especially all at once).
  * Rolling deployments might temporarily reduce capacity.
  * Harder rollback if things go wrong.

* **Use case:**

  * Development or test environments.
  * When cost and speed are higher priority than zero downtime.

---

### Summary Table

| Deployment Type            | Downtime | Rollback Ease | Cost (Extra Resources) | Use Case                     |
| -------------------------- | -------- | ------------- | ---------------------- | ---------------------------- |
| **Blue/Green**             | None     | Very Easy     | High                   | Production with max uptime   |
| **Immutable**              | None     | Easy          | Medium                 | Zero downtime, same URL      |
| **In-Place (All at Once)** | Possible | Hard          | Low                    | Dev/Test, fast deployment    |
| **In-Place (Rolling)**     | Minimal  | Medium        | Low                    | Minimize downtime, save cost |

---

**Exam Tip:**

* Blue/Green = separate env + DNS swap.
* Immutable = parallel fleet in same env.
* In-place = update existing instances directly.

---


## 4️⃣ Configuration & Customization

* Use **configuration files (.ebextensions)** for environment setup, package installation, and resource provisioning.
* Customize platform settings (instance types, scaling triggers, environment variables).
* Can add RDS databases (but tightly coupled to environment lifecycle — not recommended for production).

---

## 5️⃣ Monitoring & Troubleshooting

* Integrated with **CloudWatch** for logs, metrics, and alarms.
* Health Dashboard with status info (Green, Yellow, Red).
* Supports **log streaming** and retrieval via console or CLI.
* Can configure **Enhanced Health Reporting** for more detailed insights.

---

## 6️⃣ Security & Permissions

* EB uses **IAM roles** for managing AWS resources.
* Your app’s EC2 instances can be assigned **instance profiles** for permissions.
* You manage security groups for inbound/outbound traffic.
* Supports HTTPS termination at load balancer.

---

---

### 1️⃣ When to Use **Elastic Beanstalk (EB)** vs Direct EC2 or Containers for App Hosting

| **Criteria**                 | **Elastic Beanstalk**                                                                              | **Direct EC2 or Containers (ECS/EKS)**                                                |
| ---------------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **Ease of use**              | Very easy — manages infrastructure, scaling, load balancers automatically. Just deploy your code.  | More complex — you manage provisioning, scaling, deployment.                          |
| **Control over environment** | Limited control over underlying infrastructure. You configure via EB but no deep OS-level control. | Full control — you manage OS, networking, container orchestration.                    |
| **Customization**            | Supports configuration files (.ebextensions), but limited compared to direct access.               | Highly customizable — install any software, custom network setups, security policies. |
| **Deployment speed**         | Fast and simple deployments with built-in strategies (rolling, immutable, blue/green).             | More setup time needed — especially with containers orchestration.                    |
| **Scaling**                  | Auto scaling managed automatically based on load.                                                  | You implement and manage scaling policies yourself.                                   |
| **Use case**                 | Ideal for developers wanting to focus on code, not infrastructure. Great for web apps and APIs.    | For complex, highly customized architectures or microservices using containers.       |
| **Learning curve**           | Low to medium — abstracts infrastructure complexities.                                             | High — requires container, orchestration, and infra knowledge.                        |

---

### 2️⃣ Elastic Beanstalk Limitations — What You Should Know for the Exam

* **Limited control over infrastructure:**
  You can configure instance types, scaling, environment variables, but **cannot customize OS-level settings deeply**. For example, you can't SSH into instances and change core OS configurations extensively without affecting EB management.

* **Environment lifecycle tied to EB:**
  When you terminate an EB environment, **associated resources like RDS if created via EB are also terminated**, risking data loss. EB tightly couples resources to environment lifecycle, so separate database management is recommended.

* **Limited support for complex networking:**
  While EB supports VPCs, subnets, and security groups, it **does not support complex multi-tier or multi-VPC architectures out of the box** like you could build manually on EC2 or with containers.

* **Limited deployment customizations:**
  While .ebextensions help, certain advanced deployment or integration scenarios are **hard or impossible** without moving to custom solutions like ECS/EKS or direct EC2.

* **Platform Updates:**
  You depend on AWS to update EB platform versions for language runtimes, web servers, and middleware. This could lead to delays or forced upgrades.

* **Logging and monitoring customization:**
  Elastic Beanstalk integrates with CloudWatch, but **custom metrics or advanced monitoring requires additional manual setup** compared to full control on EC2.

---

### Exam Tip:

* Use **Elastic Beanstalk** for simple, standard web app deployments where ease and speed > full control.
* Choose **direct EC2 or container services** if you need granular infrastructure control, custom networking, or complex microservices architectures.

---

## 7️⃣ Exam Tips: Elastic Beanstalk

* Know the workflow: create application → deploy version → environment management.
* Understand deployment strategies and which provide zero downtime.
* Know when to use EB vs direct EC2/containers for app hosting.
* Be aware of EB limitations: less control over underlying resources compared to manual setups.
* Remember `.ebextensions` for customizations and advanced configs.

---

---
---
                                            # **ECS, EKS, ECR**

---
---


---

# AWS ECS, EKS, ECR — Complete Guide (Basic to Advanced for Exam)

---

## 1️⃣ Amazon ECS (Elastic Container Service)

### What is ECS?

* Managed container orchestration service to run Docker containers at scale.
* You run tasks (containerized apps) on a cluster of EC2 instances or on serverless Fargate.

---

### Basics Setup and Concepts

* **ECS Cluster:** Logical grouping of EC2 instances or Fargate capacity.
* **Task Definition:** JSON blueprint that describes containers, CPU, memory, network mode, environment variables, IAM roles, etc.
* **Service:** Defines desired task count, manages running and scaling tasks.
* **Launch Types:**

  * **EC2:** You manage infrastructure, install ECS agent on EC2 instances.
  * **Fargate:** Serverless, AWS runs infrastructure, you just define tasks.

---

### How to Set Up ECS

1. Create ECS cluster (using console or CLI).
2. Create task definition describing container(s).
3. Create ECS service using task definition.
4. Optionally, configure Load Balancer (ALB/NLB) to route traffic.
5. Scale up/down service via desired task count or autoscaling.

---

### Advanced Exam Topics

| Topic                       | Details / Exam Tips                                                                                                         |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Task Role vs Execution Role | Task Role is for containers to access AWS resources. Execution Role is for ECS to pull images, write logs. Know difference. |
| Service Auto Scaling        | Setup with CloudWatch alarms based on CPU, memory, or custom metrics. Know basic scaling policies.                          |
| Launch Type Differences     | Know trade-offs between EC2 (control) and Fargate (serverless). Cost and management implications.                           |
| Capacity Providers          | Use capacity providers to mix EC2 and Fargate in same cluster and manage scaling.                                           |
| Load Balancing              | ECS integrates with ALB/NLB, supports dynamic port mapping on EC2 launch type.                                              |
| Blue/Green Deployment       | ECS can integrate with CodeDeploy for Blue/Green deployments — important for zero downtime updates.                         |
| Service Discovery           | ECS integrates with AWS Cloud Map for internal service discovery (DNS resolution).                                          |
| IAM Integration             | Attach IAM roles to tasks (fine-grained permissions).                                                                       |

---

## 2️⃣ Amazon EKS (Elastic Kubernetes Service)

### What is EKS?

* Fully managed Kubernetes control plane by AWS.
* You manage worker nodes or run pods on Fargate.

---

### Basics Setup and Concepts

* Create EKS cluster (via Console, CLI, or `eksctl` tool).
* Setup worker nodes: EC2 instances registered with cluster or use Fargate pods.
* Use Kubernetes manifests (`yaml`) to deploy pods, services, deployments.
* Networking with AWS VPC CNI plugin — pods get IPs from VPC subnet.
* Authenticate using `aws-iam-authenticator` or AWS CLI integration.

---

### How to Set Up EKS (High-Level)

1. Create EKS cluster (managed control plane).
2. Create and attach worker nodes (or enable Fargate).
3. Configure `kubectl` to interact with cluster (`aws eks update-kubeconfig`).
4. Deploy applications using Kubernetes manifests.
5. Setup Cluster Autoscaler and Horizontal Pod Autoscaler for scaling.

---

### Advanced Exam Topics

| Topic                                 | Details / Exam Tips                                                                |
| ------------------------------------- | ---------------------------------------------------------------------------------- |
| IRSA (IAM Roles for Service Accounts) | Assign IAM permissions at pod level, improving security. Very important.           |
| Networking (VPC CNI plugin)           | Pods get IPs from VPC subnet, enabling native VPC networking.                      |
| Cluster Autoscaler                    | Automatically scales worker nodes based on pod demand.                             |
| Fargate for EKS                       | Run Kubernetes pods serverlessly without managing nodes.                           |
| Add-ons Management                    | AWS manages core Kubernetes add-ons (CoreDNS, KubeProxy). Know version management. |
| Multi-AZ High Availability            | EKS control plane runs across multiple AZs. Know why this matters.                 |
| Security and RBAC                     | Kubernetes RBAC and AWS IAM integration for access control.                        |
| Logging and Monitoring                | Use CloudWatch Container Insights or third-party tools like Prometheus.            |
| Deployments & Rollbacks               | Use Kubernetes native deployment strategies (rolling update, canary, blue/green).  |

---

## 3️⃣ Amazon ECR (Elastic Container Registry)

### What is ECR?

* Fully managed Docker container registry.
* Store, manage, and deploy container images securely.

---

### Basics Setup and Concepts

* Create ECR repository (private by default).
* Authenticate Docker client to ECR using AWS CLI.
* Build Docker images locally, tag them with ECR repo URI, and push.
* Pull images from ECR in ECS tasks or EKS pods.

---

### How to Use ECR

1. Create repository in ECR.
2. Authenticate Docker: `aws ecr get-login-password | docker login ...`
3. Build and tag image: `docker build -t myapp .` and `docker tag myapp:latest <account>.dkr.ecr.region.amazonaws.com/myapp:latest`
4. Push image: `docker push ...`
5. Reference image URI in ECS task definition or Kubernetes pod spec.

---

### Advanced Exam Topics

| Topic                         | Details / Exam Tips                                                             |
| ----------------------------- | ------------------------------------------------------------------------------- |
| Image Scanning                | Built-in vulnerability scanning integration (Amazon Inspector). Know basics.    |
| Lifecycle Policies            | Automate cleanup of old images (retention rules). Useful for cost and security. |
| Encryption                    | Images encrypted at rest using AWS KMS (default or custom key).                 |
| Cross-Region Replication      | Replicate images across regions for high availability/disaster recovery.        |
| Tag Immutability              | Prevent overwriting images to ensure deployment stability.                      |
| IAM Policies & Authentication | Know how ECR uses IAM for authentication and access control.                    |
| Integration                   | Know how ECR fits with ECS, EKS, CodeBuild, CodePipeline workflows.             |

---

# Summary and Exam Tips

| Service | Key Concepts to Remember                                                                                                       | Exam Tips                                                                               |
| ------- | ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| ECS     | Task vs Execution Roles, Fargate vs EC2, Service Auto Scaling, Blue/Green with CodeDeploy, Load Balancers                      | Understand container lifecycle and scaling. Know which launch type fits which use case. |
| EKS     | Managed control plane, worker nodes or Fargate, IRSA, Kubernetes basics (pods, deployments), Autoscaling, Security (RBAC, IAM) | Focus on Kubernetes on AWS, security integration, networking, autoscaling.              |
| ECR     | Image storage, authentication, scanning, lifecycle policies, encryption, cross-region replication                              | Know basics of container image management and security.                                 |

---

# Optional: How Deep Should You Go?

For Developer Associate:

* Focus on **conceptual understanding** and **service integrations**.
* No need to master Kubernetes internals or write complex manifests.
* Understand AWS-specific features on top of Kubernetes.
* Know CLI commands for typical workflows but don’t worry about every flag.
* Focus on how these services help developers deploy and run containerized apps.

---

---

## ✅ 🔹 ECS (Elastic Container Service)

### 1. **What is the difference between Task Role and Execution Role?**

* **Task Role**: Grants permissions **to the application inside the container**, such as access to S3, DynamoDB, etc.
* **Execution Role**: Grants ECS permission to **pull images from ECR, write logs to CloudWatch**, and other ECS-level actions.

🧠 *Tip: Task role = app’s permissions; Execution role = ECS system permissions.*

---

### 2. **When would you choose Fargate over EC2 launch type?**

* Choose **Fargate** when you want **serverless containers** (no EC2 provisioning, scaling, or patching).
* Ideal for **smaller, event-driven apps**, or **apps with unpredictable traffic**.

---

### 3. **What AWS service is used for Blue/Green deployments in ECS?**

* **AWS CodeDeploy**
  It supports Blue/Green deployments for ECS (especially **ECS with Fargate** using **Application Load Balancer**).

---

### 4. **How does ECS integrate with a Load Balancer on EC2 launch type?**

* ECS creates **target groups** for services, and **registers EC2-hosted containers** as targets.
* ALB/NLB routes requests to containers running on EC2 instances.

---

### 5. **What is a Capacity Provider in ECS?**

* A way to define **how ECS can provision infrastructure** for tasks (EC2 or Fargate).
* Helps ECS **auto-scale EC2 instances** or choose between **Fargate and Fargate Spot**.

🧠 *ECS Capacity Providers = resource supply logic.*

---

## ✅ 🔹 EKS (Elastic Kubernetes Service)

### 6. **What does IRSA stand for and why is it important?**

* **IRSA = IAM Roles for Service Accounts**
* It allows **Kubernetes pods to securely access AWS services** using IAM roles, without attaching permissions to the entire node.

---

### 7. **What is the default networking model used by EKS?**

* **Amazon VPC CNI Plugin**
* Each pod gets a **VPC-level IP address**, enabling native AWS networking and security features.

---

### 8. **How do you authenticate to an EKS cluster?**

* Using **IAM-based authentication** via `aws eks update-kubeconfig`
* Behind the scenes, EKS uses **`aws-auth` ConfigMap** to map IAM identities to Kubernetes RBAC.

---

### 9. **What is the purpose of Cluster Autoscaler vs Horizontal Pod Autoscaler?**

| Feature       | Cluster Autoscaler | Horizontal Pod Autoscaler                |
| ------------- | ------------------ | ---------------------------------------- |
| Scales Nodes? | ✅ Yes              | ❌ No                                     |
| Scales Pods?  | ❌ No               | ✅ Yes                                    |
| Works on      | Node level         | Pod level                                |
| Based on      | Pending Pods       | CPU/Memory utilization or custom metrics |

---

### 10. **What is the difference between EKS on EC2 and EKS on Fargate?**

* **EKS on EC2**: You manage worker nodes; more control and cost-effective at scale.
* **EKS on Fargate**: AWS manages compute; simpler, but **not all K8s features are supported**.

🧠 *Use EKS Fargate when you want serverless Kubernetes with limited operational burden.*

---

## ✅ 🔹 ECR (Elastic Container Registry)

### 11. **What command is used to authenticate Docker to ECR?**

```bash
aws ecr get-login-password | docker login --username AWS --password-stdin <your-registry>
```

---

### 12. **How does ECR image scanning help improve security?**

* ECR uses **Amazon Inspector** or **open-source Clair** to **scan images for vulnerabilities** in OS packages and libraries.

---

### 13. **What is a lifecycle policy in ECR?**

* A rule that **automatically deletes old or unused images**, such as untagged images older than 30 days.

---

### 14. **Why use tag immutability in ECR?**

* Prevents overwriting tags like `latest`, ensuring **image integrity and traceability** in production.

---

### 15. **Can you replicate ECR images across regions?**

* ✅ **Yes**, using **cross-region replication**.
* Helps with **multi-region deployments** and **high availability**.

---

---

## ✅ ECS Questions

### 1. **Your ECS task running on Fargate needs to access an S3 bucket. What is the correct IAM strategy?**

A. Attach an S3 access policy to the ECS execution role
B. Attach an S3 access policy to the ECS task role
C. Attach the policy to the container
D. Grant access via EC2 instance profile

✅ **Answer:** **B** — The **task role** is used to grant permissions to the app inside the container.

---

### 2. **You want to schedule ECS tasks based on a cron schedule without running a full-time service. What should you use?**

A. ECS Service
B. Lambda function
C. CloudWatch Event Rule with ECS Task
D. ECS Fargate Spot

✅ **Answer:** **C** — Use **EventBridge (formerly CloudWatch Events)** to trigger scheduled ECS Tasks.

---

### 3. **Which ECS launch type should you choose if you need the most granular control over your underlying infrastructure?**

A. Fargate
B. EC2
C. Lambda
D. App Runner

✅ **Answer:** **B** — **EC2 launch type** provides full control over instances, networking, and costs.

---

### 4. **What AWS service enables Blue/Green deployments for ECS with minimal downtime and automated rollback support?**

A. Elastic Beanstalk
B. CloudFormation
C. CodeDeploy
D. CodePipeline

✅ **Answer:** **C** — **CodeDeploy** supports **Blue/Green** deployments for ECS.

---

### 5. **In ECS, a capacity provider helps with:**

A. Assigning IAM roles to ECS containers
B. Managing how ECS schedules tasks on compute infrastructure
C. Encrypting data at rest
D. Monitoring container logs in CloudWatch

✅ **Answer:** **B** — Capacity providers let ECS manage infrastructure (e.g., Fargate, EC2 Auto Scaling).

---

## ✅ EKS Questions

### 6. **What allows EKS pods to assume IAM roles without granting permissions to the node itself?**

A. Instance Profile
B. IRSA
C. kubeconfig
D. RBAC

✅ **Answer:** **B** — **IRSA** (IAM Roles for Service Accounts) enables pod-level IAM permissions.

---

### 7. **Which component in EKS maps IAM roles to Kubernetes users and groups?**

A. IAM policy
B. aws-auth ConfigMap
C. EKS RoleBinding
D. VPC CNI plugin

✅ **Answer:** **B** — `aws-auth` ConfigMap controls IAM to Kubernetes user mapping.

---

### 8. **Which scaling mechanism in EKS adjusts the number of nodes in a cluster?**

A. Cluster Autoscaler
B. Horizontal Pod Autoscaler
C. Vertical Pod Autoscaler
D. Launch Template

✅ **Answer:** **A** — Cluster Autoscaler manages **nodes** based on pending pods.

---

## ✅ ECR Questions

### 9. **Your company requires that no developer overwrites container image tags like `v1.0`. What feature in ECR enforces this?**

A. Encryption at rest
B. Repository policy
C. Image tag immutability
D. Lifecycle policy

✅ **Answer:** **C** — **Tag immutability** prevents overwriting existing tags like `v1.0`.

---

### 10. **To reduce costs and keep your ECR registry clean, how can you automatically remove unused images?**

A. Apply an encryption policy
B. Use a registry replication rule
C. Use lifecycle policies
D. Enable scan on push

✅ **Answer:** **C** — **Lifecycle policies** can remove old or untagged images automatically.

---

---
---
---

## ✅ S3 – Exam-Critical Concepts

---

### 🔹 1. **S3 Basics**

| Concept             | Description                                     |
| ------------------- | ----------------------------------------------- |
| **Bucket**          | Global namespace (must be unique across AWS).   |
| **Object**          | File stored in S3 (key + value + metadata).     |
| **Key**             | Unique identifier for the object (like a path). |
| **Storage Classes** | Choose based on access pattern and cost.        |
| **Region-Specific** | Buckets are created in a specific region.       |

---

### 🔹 2. **Storage Classes (Very High Exam Focus)**

| Class                      | Use Case                                        |
| -------------------------- | ----------------------------------------------- |
| **Standard**               | Frequently accessed.                            |
| **IA (Infrequent Access)** | Less frequent, long-lived.                      |
| **One Zone-IA**            | Single AZ, cost-effective, low durability.      |
| **Intelligent-Tiering**    | Auto-moves data between tiers based on access.  |
| **Glacier**                | Archival (mins to hours retrieval).             |
| **Glacier Deep Archive**   | Cheapest for long-term (retrieval takes hours). |

> 🧠 **Exam Tip**: Use Glacier for backups, **Intelligent-Tiering** for unpredictable patterns, and **One Zone-IA** when data is easily reproducible.

---

### 🔹 3. **S3 Security**

| Feature                          | Description                                           |
| -------------------------------- | ----------------------------------------------------- |
| **Bucket Policies**              | JSON IAM policies attached to buckets.                |
| **IAM Policies**                 | Fine-grained access for users/roles.                  |
| **ACL (Legacy)**                 | Not preferred now; use policies instead.              |
| **Block Public Access**          | Blocks accidental public access (enabled by default). |
| **SSE (Server Side Encryption)** | Encrypts data at rest. (See below)                    |

#### 🔐 Server-Side Encryption Options:

| Type        | Key Used                 | Notes                     |
| ----------- | ------------------------ | ------------------------- |
| **SSE-S3**  | Managed by AWS (AES-256) | Default, no setup needed. |
| **SSE-KMS** | Customer-managed via KMS | Audit logs in CloudTrail. |
| **SSE-C**   | Customer provides key    | AWS never stores the key. |

> 🧠 **Exam Tip**: SSE-KMS is most secure & auditable, often mentioned in encryption scenarios.

---

### 🔹 4. **Access Control**

* Use **presigned URLs** for temporary object access.
* **Requester Pays** buckets: requester pays for data transfer.
* Use **Access Points** for large-scale multi-application access.

---

### 🔹 5. **Versioning, MFA Delete, Lifecycle Rules**

| Feature             | Purpose                                                         |
| ------------------- | --------------------------------------------------------------- |
| **Versioning**      | Keep multiple versions of the same object.                      |
| **MFA Delete**      | Prevent deletion without MFA.                                   |
| **Lifecycle Rules** | Auto-transition or expire data (e.g., Standard → IA → Glacier). |

> 🧠 **Exam Tip**: Versioning is **required for MFA Delete** and **important for rollback scenarios**.

---

### 🔹 6. **Cross-Region Replication (CRR)**

* Automatically replicate objects to another bucket in another region.
* Requires **versioning enabled** on both source and destination.

---

### 🔹 7. **Static Website Hosting**

* Enable from bucket properties.
* Needs `index.html` and optional `error.html`.
* Must make bucket/object **public** (or use CloudFront for security).

---

### 🔹 8. **Event Notifications (S3 → Trigger)**

| Integration | Use                          |
| ----------- | ---------------------------- |
| **SNS**     | Publish notification.        |
| **SQS**     | Queue object change events.  |
| **Lambda**  | Process files automatically. |

> 🧠 **Exam Tip**: Use Lambda for serverless processing (e.g., auto-resize images).

---

### 🔹 9. **Performance Optimization**

| Feature                      | Description                             |
| ---------------------------- | --------------------------------------- |
| **Multipart Upload**         | For files > 100MB (required > 5GB).     |
| **Byte-Range Fetch**         | Download parts of a file in parallel.   |
| **S3 Transfer Acceleration** | Speeds up uploads using edge locations. |

---

### 🔹 10. **Consistency Model**

* **Strong consistency** for new and overwrite PUTs and DELETEs (no eventual consistency anymore).
* Immediately available after upload/delete.

---

### 🧠 Quick Exam Revision Table

| Topic                     | Quick Hint                                                     |
| ------------------------- | -------------------------------------------------------------- |
| **Encryption Type**       | SSE-S3 (default), SSE-KMS (auditable), SSE-C (you manage key). |
| **Versioning**            | Supports rollback, required for CRR & MFA delete.              |
| **CRR**                   | Needs versioning on both buckets.                              |
| **Lifecycle Rule**        | Auto move/delete based on age.                                 |
| **Presigned URLs**        | Temporary, secure access.                                      |
| **Static Hosting**        | Must make objects public.                                      |
| **S3 Events**             | Can trigger Lambda/SNS/SQS.                                    |
| **Access Point**          | Alternate way to manage access.                                |
| **Transfer Acceleration** | Faster upload from distant users.                              |
| **Multipart Upload**      | Must for files > 5GB.                                          |

---

---

## ✅ S3 – **Advanced Topics for the Exam**

---

### 🔹 1. **S3 Object Lock & Compliance Mode**

| Feature             | Description                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------- |
| **Object Lock**     | Prevents deletion of objects for a fixed retention period (WORM – Write Once Read Many). |
| **Governance Mode** | Users with special permission can override/delete objects.                               |
| **Compliance Mode** | Even root users cannot delete/modify until retention expires.                            |

> 🧠 **Exam Scenario**: Financial data retention — use **Compliance Mode**.

---

### 🔹 2. **S3 Select vs Glacier Select**

| Feature            | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| **S3 Select**      | Run SQL-like queries **on objects (CSV/JSON)** without downloading. |
| **Glacier Select** | Same for archived data in Glacier.                                  |

> 🧠 **Exam Tip**: Use S3 Select to improve performance when only a portion of large files is needed.

---

### 🔹 3. **Requester Pays Buckets**

* Cost of **data transfer and request charges** billed to requester, not the bucket owner.
* Common when public data is served but costs shouldn't be paid by data owner.

> 🧠 **Exam Scenario**: “Your org shares large data sets to the public. How do you offload cost?” → Use **Requester Pays**.

---

### 🔹 4. **S3 Access Analyzer**

* Identifies buckets that are publicly accessible or accessible by other accounts.
* Great for **security auditing** and **exam questions about misconfiguration**.

---

### 🔹 5. **S3 Inventory**

* Provides a **CSV file list** of objects in a bucket daily or weekly.
* Helps with **auditing and compliance**.

> 🧠 Exam Tip: For bucket content auditing **at scale**, use **S3 Inventory**.

---

### 🔹 6. **S3 Replication (Advanced Types)**

| Type                               | Description                                             |
| ---------------------------------- | ------------------------------------------------------- |
| **CRR**                            | Cross-Region Replication.                               |
| **SRR**                            | Same-Region Replication.                                |
| **Replicate Delete Markers**       | Optional; helps maintain sync.                          |
| **Replication Time Control (RTC)** | SLA-backed <15 minutes replication time (paid feature). |

> 🧠 **Exam Scenario**: Low-latency regional backup or multi-account replication → RTC.

---

### 🔹 7. **S3 Event Bridge Integration (Advanced Events)**

* Besides Lambda/SNS/SQS, **S3 can send object events to EventBridge**.
* Allows **rule-based triggers across AWS services**.

---

### 🔹 8. **S3 Multi-Region Access Points (Newer/Advanced)**

* Automatically routes requests to the closest region (best latency).
* Useful for **multi-region, global applications**.

> 🧠 Exam Tip: For global user access with lowest latency → use **S3 Multi-Region Access Points**.

---

### 🔹 9. **Access Points & VPC Endpoints**

| Feature                         | Description                                                         |
| ------------------------------- | ------------------------------------------------------------------- |
| **Access Points**               | Create custom access policy per app/user.                           |
| **VPC Endpoint (Gateway Type)** | Private connection from your VPC to S3 **without public internet**. |

> 🧠 Exam Scenario: Secure S3 access from private subnet? → Use **Gateway VPC Endpoint**.

---

### 🔹 10. **S3 Performance Optimization (Deep)**

| Feature                    | Why It’s Important                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Parallelization**        | Prefix is no longer a bottleneck, but for older questions, know that adding prefixes increases performance. |
| **Upload Parallelization** | Multipart upload lets you upload chunks in parallel.                                                        |
| **Byte-Range Fetches**     | Parallel download of object parts.                                                                          |
| **Transfer Acceleration**  | Uses CloudFront edge locations to speed uploads.                                                            |

---

## 🔸 Common Exam Scenarios

| Scenario                                | What to Use                          |
| --------------------------------------- | ------------------------------------ |
| Secure access to S3 without public IPs  | VPC Endpoint (Gateway type)          |
| Prevent object deletions completely     | Object Lock (Compliance Mode)        |
| Backup S3 across regions                | CRR + Versioning                     |
| Reduce retrieval cost/time from Glacier | Glacier Select or S3 Lifecycle rules |
| Allow temporary download access         | Presigned URL                        |
| Audit S3 contents                       | S3 Inventory                         |
| Detect public access misconfigs         | S3 Access Analyzer                   |

---

🔹 7. S3 on Outposts & DataSync
S3 on Outposts: Store data on-premises via Outposts (exam will hint at “local storage in your data center”).

AWS DataSync: Automate transferring large data sets to/from S3.

Exam Tip: When you see “low-latency local access to S3” or “on-premises S3,” think S3 on Outposts.

---

## ✅ S3 CORS (Cross-Origin Resource Sharing)

### 🔹 What is CORS?

CORS is a **browser security feature** that restricts web pages from making **requests to a domain different from the one that served the web page** (called a "cross-origin" request).

If your **JavaScript frontend (e.g., React app)** is hosted at `https://myfrontend.site` and tries to fetch from `https://mybucket.s3.amazonaws.com`, that’s **cross-origin**.

To allow this, you must define **CORS rules on the S3 bucket**.

---

### 🔹 Sample CORS Configuration

```xml
<CORSConfiguration>
  <CORSRule>
    <AllowedOrigin>https://myfrontend.site</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
    <ExposeHeader>ETag</ExposeHeader>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
  </CORSRule>
</CORSConfiguration>
```

### 🔹 Explanation:

| Tag             | Meaning                                                      |
| --------------- | ------------------------------------------------------------ |
| `AllowedOrigin` | Which origin is allowed to access (e.g., your frontend URL). |
| `AllowedMethod` | Which HTTP methods (GET, POST, PUT, etc.) are allowed.       |
| `AllowedHeader` | Which headers are allowed in the actual request.             |
| `ExposeHeader`  | Headers exposed to the browser (e.g., `ETag`).               |
| `MaxAgeSeconds` | How long browser can cache the preflight request result.     |

---

### 🔸 Exam Scenarios:

| Scenario                                                         | What to Remember                            |
| ---------------------------------------------------------------- | ------------------------------------------- |
| S3 bucket used as image/video/static content source for a JS app | You need CORS on the bucket.                |
| App failing with CORS errors in browser                          | Add `AllowedOrigin` matching frontend URL.  |
| Wildcards allowed?                                               | Yes: `*` allowed for public access (risky). |

> 🧠 **Exam Tip**: CORS is NOT needed for requests from EC2/Lambda/backend. Only **browser-based** (JS frontend) access needs it.

---
---
---


## 🔍 **Monitoring in AWS – Exam-Focused Breakdown**

AWS provides several monitoring tools. You need to know **when and why to use each**:

---

### 🔸 **1. Amazon CloudWatch** – ⭐ Very Important

| **Feature**                  | **Description**                                                             | **Exam Tips**                                                 |
| ---------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Metrics**                  | Numeric data points for resources (e.g., CPUUtilization, Invocations, etc.) | Know **default vs custom metrics**.                           |
| **Logs**                     | Collects logs (e.g., Lambda, EC2, API Gateway, ECS)                         | Use **CloudWatch Agent** or **Lambda log integration**.       |
| **Alarms**                   | Trigger based on metric thresholds                                          | Useful with **Auto Scaling**, **SNS**, etc.                   |
| **Dashboards**               | Visualize metrics in a custom dashboard                                     | Create for better insights.                                   |
| **Events / EventBridge**     | Respond to changes in AWS (e.g., EC2 state changes, scheduled tasks)        | Know difference between **EventBridge vs CloudWatch Alarms**. |
| **CloudWatch Logs Insights** | SQL-like queries on logs                                                    | Useful for analyzing logs quickly.                            |

---

### 🔸 **2. AWS X-Ray** – 💡 For Tracing

| **Feature**            | **Description**                                                 | **Exam Tips**                               |
| ---------------------- | --------------------------------------------------------------- | ------------------------------------------- |
| Traces                 | Visualizes latency of requests through your app (microservices) | Use with **Lambda, API Gateway, ECS, etc.** |
| Segments & Subsegments | Breakdown of service/component processing time                  | Helps identify **performance bottlenecks**  |
| Integrated Services    | Lambda, ECS, Beanstalk, API Gateway, EC2, ALB                   | Know how to **instrument code** using SDK   |

---

### 🔸 **3. AWS CloudTrail** – 🎥 For Auditing

| **Feature**       | **Description**                                                        | **Exam Tips**                                                      |
| ----------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Event History     | Records all **API calls** made in your account (via SDK, CLI, Console) | Use to detect **unauthorized access** or debug failed deployments. |
| Management Events | By default, includes **create/read/update/delete** on AWS resources    | Free for 90 days (event history).                                  |
| Data Events       | Logs **S3 object-level** or **Lambda invoke** activity                 | Must be **enabled explicitly**, **incurs cost**.                   |
| Trail             | A configuration to send logs to S3, CloudWatch Logs, etc.              | Needed for **cross-region**, **org-wide** monitoring.              |

---

### 🔸 **4. VPC Flow Logs** – 🌐 Network Visibility

| **Feature**              | **Description**                                    | **Exam Tips**                                       |
| ------------------------ | -------------------------------------------------- | --------------------------------------------------- |
| Log IP traffic           | Captures inbound/outbound traffic at **ENI level** | Useful for **network troubleshooting**              |
| Sent to CloudWatch or S3 | You must configure it                              | Choose **CloudWatch Logs** for real-time inspection |

---

## 🧠 Summary Table – Monitoring Services

| **Service**              | **Purpose**                   | **Integrated With**                 |
| ------------------------ | ----------------------------- | ----------------------------------- |
| CloudWatch               | Metrics, Logs, Alarms         | EC2, Lambda, RDS, API Gateway, etc. |
| CloudTrail               | Audit API Calls               | All AWS Services                    |
| AWS X-Ray                | Tracing requests, performance | Lambda, Beanstalk, ECS, API Gateway |
| VPC Flow Logs            | Network traffic visibility    | ENIs in VPC                         |
| CloudWatch Agent         | Send OS-level metrics/logs    | EC2, On-premise servers             |
| CloudWatch Logs Insights | Search/analyze logs           | Lambda, ECS, API Gateway logs, etc. |

---

---

## 🔥 Advanced Monitoring Topics for AWS Developer Associate

---

### 🔹 1. **CloudWatch Embedded Metric Format (EMF)** – 🧠 *Highly Tested*

| Feature                                                  | Description                                                               |
| -------------------------------------------------------- | ------------------------------------------------------------------------- |
| Allows logging **custom metrics inside structured logs** | Instead of sending metrics and logs separately                            |
| Use case                                                 | Custom business metrics in Lambda or container apps                       |
| Example                                                  | Log JSON like `{"_aws": {"Timestamp":12345, "CloudWatchMetrics":[...]} }` |
| Benefit                                                  | No need for separate `PutMetricData` calls — **cheaper, scalable**        |
| Exam Tip                                                 | Know how EMF can reduce API calls and cost                                |

---

### 🔹 2. **CloudWatch Metric Math** – 🧠 Hidden Gem

| Feature                                    | Description                                                               |
| ------------------------------------------ | ------------------------------------------------------------------------- |
| Create **math expressions** across metrics | `sum`, `avg`, `rate`, `IF` logic etc.                                     |
| Use case                                   | Custom health status (`IF cpu > 70 then alert`)                           |
| Exam Tip                                   | Know how to **combine metrics (EC2+RDS)** or **derive synthetic metrics** |

---

### 🔹 3. **Custom Metrics** – Important Edge Case

| Feature                        | Description                                             |
| ------------------------------ | ------------------------------------------------------- |
| Sent using `PutMetricData` API | Can attach dimensions, units                            |
| Cost                           | Billed separately — **watch for excess custom metrics** |
| Retention                      | 15 months (granularity changes over time)               |
| Dimensions                     | Avoid too many — max 30 per metric                      |

---

### 🔹 4. **Detailed Monitoring vs Basic Monitoring** (EC2)

| Type     | Frequency                                                                                 | Cost |
| -------- | ----------------------------------------------------------------------------------------- | ---- |
| Basic    | 5 min                                                                                     | Free |
| Detailed | 1 min                                                                                     | \$\$ |
| Exam Tip | Use **Detailed Monitoring** for **faster Auto Scaling** or close watch on app load spikes |      |

---

### 🔹 5. **CloudWatch Anomaly Detection** – ✅ Covered Often

| Feature                                         | Description                                             |
| ----------------------------------------------- | ------------------------------------------------------- |
| Uses ML to **predict normal range** of a metric | Detects sudden spikes/drops                             |
| Use case                                        | CPU usage suddenly goes to 90%                          |
| Exam Tip                                        | Know how it **auto adjusts alarm thresholds** over time |

---

### 🔹 6. **CloudWatch Contributor Insights** – 💥 Pro Tip

| Feature                                   | Description                                                            |
| ----------------------------------------- | ---------------------------------------------------------------------- |
| Analyze logs to find **top contributors** | e.g., which IP causes most 5xx                                         |
| Works on                                  | CloudWatch Logs (Lambda/API Gateway), VPC flow logs                    |
| Exam Tip                                  | Know how to use it to **detect DDoS patterns or performance hotspots** |

---

### 🔹 7. **CloudWatch Synthetics (Canaries)** – 👀 Exam-Ready

| Feature                                           | Description                                                            |
| ------------------------------------------------- | ---------------------------------------------------------------------- |
| Automated scripts that simulate user interactions | Browser-based or HTTP checks                                           |
| Use case                                          | Monitor API uptime / front-end responsiveness                          |
| Language                                          | Node.js or Python                                                      |
| Exam Tip                                          | Know how to use **Synthetics with X-Ray** for end-to-end observability |

---

### 🔹 8. **X-Ray Sampling Rules** – Deep Cut

| Feature                            | Description                               |
| ---------------------------------- | ----------------------------------------- |
| Controls which requests get traced | Default: 1 req/sec + 5% of others         |
| Use case                           | Prevent cost overrun in high-traffic apps |
| Custom Rules                       | Path-based or service-based sampling      |

---

### 🔹 9. **Cross-Account Observability** – New & Exam-worthy

| Feature                                                              | Description                                           |
| -------------------------------------------------------------------- | ----------------------------------------------------- |
| Centralized observability of CloudWatch metrics/logs across accounts | Use **linked accounts and dashboards**                |
| Benefit                                                              | Great for orgs with dev/test/prod separation          |
| Exam Tip                                                             | Know how to **enable sharing via CloudWatch Console** |

---

### 🔹 10. **EventBridge vs CloudWatch Events** – Subtle Trick

| Difference                     | Description                                                                                    |
| ------------------------------ | ---------------------------------------------------------------------------------------------- |
| CloudWatch Events = older name | EventBridge = **newer**, supports 3rd party SaaS                                               |
| Exam Tip                       | Know that **EventBridge pipes**, schema discovery, and bus-to-bus model is only in EventBridge |

---

## 🧠 Summary Table – Pro Level Comparison

| **Feature**        | **Basic Use**           | **Advanced Exam Use**                              |
| ------------------ | ----------------------- | -------------------------------------------------- |
| CloudWatch Metrics | EC2/Lambda CPU, Memory  | Custom metrics, metric math, anomaly detection     |
| CloudWatch Logs    | Lambda logs             | Contributor insights, Logs Insights queries        |
| CloudWatch Alarms  | CPU > 80%               | Composite alarms, integrated with EMF              |
| CloudWatch Events  | EC2 start/stop triggers | Use **EventBridge Pipes**, **Cross-account buses** |
| CloudTrail         | Auditing                | Data events (S3, Lambda), org trails               |
| X-Ray              | Lambda traces           | Trace groups, sampling rules                       |
| VPC Flow Logs      | Network flow visibility | Used with Contributor Insights                     |
| Synthetics         | API/website checks      | Synthetics with screenshots + X-Ray                |

---

## 💡 Final Exam Tips

✅ Know **how different monitoring tools complement each other** — for example:

* Use **CloudTrail + CloudWatch Logs + Alarms** to detect unauthorized access.
* Use **X-Ray + CW Logs + Metrics** for microservices visibility.
* Use **EventBridge + Lambda** for automated reactions.

✅ Focus on **cost vs benefit**:

* Custom metrics = paid.
* Detailed monitoring = paid.
* Log retention can


---

## 🔶 1. **Custom Metrics (CloudWatch)**

### ✅ What Are They?

AWS services push **default metrics**, but when you want to **track app-specific behavior**, you use **custom metrics**.

### 🔹 How to Send Custom Metrics:

* Use AWS CLI:

  ```bash
  aws cloudwatch put-metric-data --metric-name MyMetric --namespace MyApp --value 100
  ```
* From a Lambda function:

  * Use SDK (`PutMetricData`)
  * Or use **Embedded Metric Format (EMF)** with `console.log`

### 🔹 Key Properties

| Feature     | Value                                     |
| ----------- | ----------------------------------------- |
| Namespace   | Logical grouping (e.g. `MyApp`)           |
| Metric Name | `LoginFailures`, `QueueDepth`             |
| Dimensions  | Key-value pairs (e.g. `InstanceId=i-123`) |
| Resolution  | Standard (1 min), High-Res (1 sec)        |
| Retention   | 15 months (granularity drops over time)   |

---

### ✅ **1. Resolution**

**Resolution** refers to the **frequency** or **granularity** at which metric data points are recorded and available.

| Type                | Interval               | Use Case Example                                   |
| ------------------- | ---------------------- | -------------------------------------------------- |
| **Standard**        | Every **1 minute**     | EC2, RDS default metrics, suitable for most alerts |
| **High-Resolution** | As low as **1 second** | Custom metrics (like real-time API response time)  |

* **Default AWS metrics** (like EC2 CPUUtilization) use **standard resolution** (1-min).
* **High-resolution metrics** (aka sub-minute) can capture spikes better but **cost more**.

**Example**:

```bash
aws cloudwatch put-metric-data \
  --metric-name MyHighResMetric \
  --namespace MyApp \
  --value 10 \
  --storage-resolution 1   # 1 second
```

---

### ✅ **2. Dimension**

**Dimensions** are **name/value pairs** that are used to **filter and categorize** your metrics. They help **group and query metrics more specifically**.

| Example Metric       | Dimension Key      | Dimension Value     |
| -------------------- | ------------------ | ------------------- |
| `CPUUtilization`     | `InstanceId`       | `i-0abcd1234ef5678` |
| `RequestCount` (ELB) | `LoadBalancerName` | `my-app-lb`         |
| `CustomMetric`       | `Environment`      | `Prod`              |

* You can **add up to 10 dimensions per metric**.
* Metrics with **different dimensions are treated as separate metrics**.

> 💡 Think of dimensions like tags or labels to slice and dice your data.

---

### 🔁 Real-World Analogy

| Concept    | Analogy                                                                        |
| ---------- | ------------------------------------------------------------------------------ |
| Resolution | How often a thermometer records temperature (once a minute or once per second) |
| Dimension  | Where the thermometer is placed (living room vs kitchen)                       |

---

🔍 Dimensions are metadata (labels/tags) that help categorize, filter, and search for your metrics — they are NOT the actual metric values.

---

### ⚠️ Exam Tip:

* **High-resolution metrics** support **sub-minute alarms**.
* **Dimensions** are crucial for creating **specific alarms or dashboards** (e.g., CPUUtilization of a single instance vs all instances).
* Changing dimension = creating a **new unique metric stream**.

---

### 🔹 Use Cases:

* Track app-level failures
* Number of items in custom queue
* Response time from external APIs

### ⚠️ Exam Tips:

* Custom metrics **incur additional cost**.
* **High-resolution metrics (1 sec)** = more cost.
* Use **up to 10 dimensions**, but keep them consistent.
* You can **create alarms** on custom metrics like default ones.

---

## 🔶 2. **Detailed Monitoring (EC2)**

### ✅ What is it?

By default, EC2 sends metrics to CloudWatch every **5 minutes**. Enabling **detailed monitoring** changes it to **1-minute granularity**.

### 🔹 Key Comparison:

| Feature     | Basic Monitoring | Detailed Monitoring         |
| ----------- | ---------------- | --------------------------- |
| Frequency   | Every 5 minutes  | Every 1 minute              |
| Cost        | Free             | Paid                        |
| Granularity | Lower            | Higher                      |
| Use case    | General ops      | Auto Scaling, sudden spikes |

### 🔹 Use Cases:

* Set fast-reacting alarms (e.g., CPU spike)
* **Auto Scaling groups** need **1-min metrics** to scale quickly
* Granular billing or chargeback tracking

### 🔹 How to Enable:

* Check when launching an EC2 instance: “Enable Detailed Monitoring”
* Or use CLI:

  ```bash
  aws ec2 monitor-instances --instance-ids i-12345678
  ```

### ⚠️ Exam Tips:

* **Auto Scaling policies** work better with detailed monitoring.
* Can be **enabled/disabled anytime**, no reboot needed.
* Billed **per instance per month**.

---

## 🔶 3. **CloudWatch Synthetics (Canaries)**

### ✅ What is it?

**Canaries** are small programs that run on a schedule to **simulate user interactions** — like visiting a website or pinging an API — and alert if it fails.

### 🔹 Key Features:

| Feature   | Value                                |
| --------- | ------------------------------------ |
| Language  | Node.js or Python                    |
| Use Case  | API/website uptime checks            |
| Locations | Global regions                       |
| Frequency | As low as every 1 min                |
| Retention | 31 days logs + screenshots           |
| Visual    | Can take **screenshots** of failures |

### 🔹 Types of Canaries:

* **Heartbeat**: Ping an endpoint for uptime
* **Scripted**: Use Puppeteer (Node.js) or Selenium (Python) to interact with frontend

### 🔹 Integration:

* CloudWatch Alarms
* CloudWatch Logs (stores logs)
* **CloudWatch X-Ray** for tracing
* EventBridge for automation on failure

### 🔹 Example Use Case:

```javascript
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const https = require('https');

const apiCanaryBlueprint = async function () {
    let requestOptions = {
        hostname: "myapi.example.com",
        method: "GET",
        path: "/health"
    };
    let response = await synthetics.executeHttpStep("Check API", requestOptions);
};
```

### ⚠️ Exam Tips:

* Know that **Synthetics help detect outages before customers do**.
* Know **how they integrate with CloudWatch/X-Ray**.
* Exam may ask: *“Which service helps simulate user interaction in a production app?”*

---

## 💡 Summary Table – Comparison

| Feature          | Custom Metrics     | Detailed Monitoring      | Synthetics Canaries              |
| ---------------- | ------------------ | ------------------------ | -------------------------------- |
| Purpose          | App-level metrics  | Frequent infra metrics   | Simulate user/API interaction    |
| Setup            | SDK/CLI/EMF        | EC2 Setting              | Scripted in Node/Python          |
| Cost             | Per metric         | Per instance             | Per run (frequency + region)     |
| Use with Alarms? | ✅                  | ✅                        | ✅                                |
| Real Use Case    | Queue size, errors | Trigger ASG on CPU spike | Website/API uptime               |
| Exam Relevance   | High               | Medium to High           | High (real-world app monitoring) |

---

---

## ✅ 1. **Amazon EventBridge (formerly CloudWatch Events)**

### 🔹 What It Is:

A **serverless event bus** that connects applications using events from AWS services, your applications, or SaaS platforms.

---

### 🔧 How It Works:

1. **Event Source**: AWS services (e.g., EC2, S3), custom apps, or SaaS.
2. **Event Bus**: Receives events (default, partner, or custom).
3. **Rules**: Match events using pattern filtering (e.g., eventName = `RunInstances`).
4. **Target**: Sends matched events to targets like Lambda, Step Functions, SNS, SQS, etc.

---

### 🧠 Must-Know Concepts (Exam Tips):

| Concept               | Description/Example                                                             |
| --------------------- | ------------------------------------------------------------------------------- |
| **Default Event Bus** | All AWS services publish events here automatically.                             |
| **Custom Event Bus**  | You create this for your **own apps** or **partner SaaS** apps.                 |
| **Event Pattern**     | JSON pattern used to match incoming events (not a full JSON match).             |
| **Event Archive**     | Retain events and replay them later (for debugging or testing workflows).       |
| **Schema Registry**   | Auto-discovers JSON schemas and saves them (integrates with IDEs like VS Code). |
| **Event Replay**      | Replays past events from an archive to test or retry processing logic.          |

---

### 📌 Example Event Pattern (Match EC2 start events):

```json
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running"]
  }
}
```

---

### 🎯 Common Targets:

* **Lambda** (common in exam scenarios!)
* **Step Functions**
* **SQS/SNS**
* **ECS task**
* **Kinesis stream**

---

### 📝 Pro Tips for the Exam:

* Know **how to match events using patterns**.
* Know when to use **EventBridge vs SNS/SQS**:

  * Use **EventBridge** for **routing based on event content**.
  * Use **SNS** for **fan-out** pub/sub messaging.
* **EventBridge can schedule events** (like cron jobs).
* **CloudTrail can be a source** → EventBridge rule triggers on API calls.

---

## ✅ 2. **AWS CloudTrail**

### 🔹 What It Is:

Records **every API call** (management events) and **data events** (like S3 object-level or Lambda invoke events) across your AWS account.

---

### 🔧 Types of Events:

| Type                  | Description                                                         |
| --------------------- | ------------------------------------------------------------------- |
| **Management Events** | CRUD operations on resources (e.g., create-bucket, start-instance). |
| **Data Events**       | Object-level actions (e.g., GetObject in S3, Invoke in Lambda).     |
| **Insights Events**   | Detects **unusual API activity** (requires CloudTrail Insights).    |

---

### 📂 Where Is It Stored?

* **S3 bucket** (JSON files)
* Optional: **CloudWatch Logs** (for real-time alerts)

---

### 🧠 Must-Know for Exam:

| Topic                        | Explanation                                                              |
| ---------------------------- | ------------------------------------------------------------------------ |
| **Trail**                    | A configuration to record events and store them (S3 or CloudWatch).      |
| **Single vs Multi-region**   | Single region (default) vs. Multi-region (recommended for global audit). |
| **CloudTrail Insights**      | Detects anomalies in behavior (e.g., spike in EC2 StopInstances).        |
| **EventBridge + CloudTrail** | Use EventBridge to react to CloudTrail events in near real-time.         |
| **Lookup Events**            | Use `aws cloudtrail lookup-events` to find who did what and when.        |

---

### 📌 CLI Example: Who deleted my EC2?

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=TerminateInstances
```

---

### 🎓 Sample Exam Scenario:

> You want to take action (send an email, trigger Lambda) **whenever someone disables a CloudTrail trail**.

* ✅ Use **EventBridge** to match the API call `StopLogging` from CloudTrail events.
* ✅ Set the **target** as Lambda or SNS.

---

## ✅ Summary Table:

| Service         | Purpose                              | Key Use Case                             |
| --------------- | ------------------------------------ | ---------------------------------------- |
| **EventBridge** | Event-driven routing & orchestration | Trigger Lambda when EC2 starts           |
| **CloudTrail**  | API auditing + data event recording  | Track who deleted an S3 bucket           |
| **Integration** | EventBridge rule based on CloudTrail | Auto-response to security-sensitive APIs |

---

## 📌 Practice Questions (Active Recall)

1. What’s the difference between CloudTrail and CloudWatch Logs?
2. How would you monitor S3 object-level API calls?
3. Which service is used for tracing requests in microservice-based apps?
4. What tool can you use to monitor the network traffic in a private subnet?
5. Which service can trigger Lambda functions based on scheduled events?

---
---
---


---

## ✅ VPC – Quick Overview (Foundational)

| Term                       | Description                                               |
| -------------------------- | --------------------------------------------------------- |
| **VPC**                    | Your **isolated virtual network** in AWS                  |
| **CIDR block**             | IP range (e.g., `10.0.0.0/16`)                            |
| **Subnets**                | Divide VPC into **smaller IP ranges** (Public/Private)    |
| **Internet Gateway (IGW)** | Allows **public internet access**                         |
| **NAT Gateway**            | Private subnets can reach internet but **not be reached** |
| **Route Table**            | Controls **traffic flow** in/out of subnets               |
| **Security Group**         | **Stateful** virtual firewall for EC2/LB                  |
| **NACL (Network ACL)**     | **Stateless** firewall at **subnet level**                |

---

## ✅ VPC Exam-Relevant Deep Topics

### 1. **Public vs Private Subnet**

| Type    | Internet Access         | Common Use                  |
| ------- | ----------------------- | --------------------------- |
| Public  | Yes (via IGW)           | Web servers, Load Balancers |
| Private | Outbound only (via NAT) | Databases, App servers      |

🧠 **Exam tip:** A subnet becomes *public* if it has a **route to IGW** and associated **public IP**.

---

### 2. **NAT Gateway vs NAT Instance**

| Feature     | NAT Gateway (Managed) | NAT Instance (EC2) |
| ----------- | --------------------- | ------------------ |
| Scalability | Auto scale            | Manual             |
| HA          | In multi-AZ setup     | You build yourself |
| Cost        | \$\$\$                | Cheaper (but DIY)  |

🧠 **Exam tip:** NAT Gateway **must be in a public subnet**, and private subnets should route to it.

---

### 3. **VPC Peering vs Transit Gateway**

| Feature            | VPC Peering           | Transit Gateway                 |
| ------------------ | --------------------- | ------------------------------- |
| Scope              | **1-to-1** connection | **Hub-and-spoke**               |
| Transitive routing | ❌ Not supported       | ✅ Supported                     |
| Use case           | Small environments    | Complex, large-scale networking |

---

### 4. **VPC Endpoints**

| Type          | Description                                     | Example                      |
| ------------- | ----------------------------------------------- | ---------------------------- |
| **Gateway**   | Used for **S3 and DynamoDB**                    | Keeps traffic **within AWS** |
| **Interface** | Used for other services (e.g., SSM, CloudWatch) | Creates **ENI** in subnet    |

🧠 **Exam tip:** **No IGW/NAT** is required when using VPC endpoints — great for private connectivity.

---

### 5. **Elastic IPs & ENIs**

* **Elastic IP:** Static public IPv4 address you can attach to EC2, NAT, etc.
* **ENI (Elastic Network Interface):** Virtual NIC, can be moved between EC2s.

🧠 ENIs can have multiple **private IPs** and **security groups**, useful in failover setups.

---

### 6. **Flow Logs**

* Capture IP traffic at **VPC, subnet, or ENI level**
* Useful for **monitoring**, **troubleshooting**, and **auditing**

🧠 Exported to CloudWatch or S3. Can be a **source for security investigations**.

---

### 7. **Custom Route Tables**

Each subnet must be associated with **exactly one route table**.

* **Main Route Table** = Default for subnets unless otherwise specified.
* **Exam Tip:** If a **private subnet is getting internet**, check if it’s incorrectly pointing to IGW instead of NAT.

---

## 🔐 Security in VPC

| Concept             | Stateful? | Applied To     | Key Point          |
| ------------------- | --------- | -------------- | ------------------ |
| **Security Groups** | ✅         | Instance Level | Allow rules only   |
| **NACLs**           | ❌         | Subnet Level   | Allow & Deny rules |

🧠 Security Group = **Default deny**, then allow.
🧠 NACL = You must define **both inbound & outbound rules**.

---

## 🧠 Exam Tips (VPC)

| Tip                                                                                        |
| ------------------------------------------------------------------------------------------ |
| You can’t assign a **public IP** in a subnet **without a route to IGW**                    |
| Default VPC comes with **public subnet**, IGW, route table, and security group             |
| **You must deploy NAT Gateway in public subnet**                                           |
| **VPC Peering is NOT transitive**, Transit Gateway is                                      |
| Know which services support **VPC endpoints** (S3, DynamoDB = Gateway; others = Interface) |
| **Subnet CIDRs must not overlap**, even across peered VPCs                                 |

---

## 🔁 Summary Table

| Feature         | Key Point                                |
| --------------- | ---------------------------------------- |
| IGW             | Required for public internet access      |
| NAT Gateway     | For outbound access from private subnets |
| Route Table     | Controls subnet routing                  |
| VPC Peering     | One-to-one, no transitive routing        |
| Transit Gateway | Hub-and-spoke, scalable                  |
| VPC Endpoints   | Private access to AWS services           |
| Flow Logs       | Capture IP-level data                    |
| NACL            | Stateless firewall                       |
| Security Group  | Stateful, EC2-level                      |

---
---
---

# 🧪 AWS CI/CD Stack: Deep Dive from Zero to Advanced

---

## 🧱 1. CodeCommit (Git Repo on AWS)

### 🔹 What is CodeCommit?

* It’s AWS’s **fully-managed Git-based source control** service.
* Think of it like GitHub or Bitbucket, but **private, secure, and integrated with IAM**.

### 🔹 How to Set It Up (Basics):

1. **Create a repository** in CodeCommit.
2. Clone it locally:

   ```bash
   git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/my-repo
   ```
3. **Authenticate via**:

   * HTTPS using IAM credentials + AWS credential helper
   * SSH using public/private key pair uploaded to IAM

---

### 🔐 IAM & Authentication for CodeCommit:

You must:

* Attach **CodeCommit permissions** (`AWSCodeCommitFullAccess`, ideally a custom least-privilege version).
* Set up credentials in `.git/config` or use AWS credential helper:

  ```bash
  git config --global credential.helper '!aws codecommit credential-helper $@'
  ```

---

## 🧪 2. CodeBuild (Build and Package Your App)

---

### 🔹 What is CodeBuild?

* A **fully managed build service** that compiles your source code, runs tests, and produces deployable artifacts.
* It's **language-agnostic**, supporting Docker, Node.js, Java, Python, etc.

---

### 🧾 `buildspec.yml` — THE Heart of CodeBuild

This YAML file **tells CodeBuild what to do**.

### ✅ Minimal Example:

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 14
  build:
    commands:
      - npm install
      - npm run build

artifacts:
  files:
    - '**/*'
```

---

### 🔍 Full Anatomy of `buildspec.yml`

```yaml
version: 0.2

env:                           # Optional: Environment variables
  variables:
    ENV: prod

phases:
  install:
    runtime-versions:          # Pre-built environments
      python: 3.9
      java: corretto11
    commands:
      - echo Installing dependencies...
      - pip install -r requirements.txt
  pre_build:
    commands:
      - echo Logging into ECR...
      - aws ecr get-login-password | docker login
  build:
    commands:
      - echo Building Docker image...
      - docker build -t my-image .
  post_build:
    commands:
      - echo Pushing image to ECR...
      - docker push my-image

artifacts:                     # Files to export to S3 (for CodeDeploy etc.)
  files:
    - '**/*'
  name: my-output-artifacts
```

---

### 🔧 `install:` Phase

> 🧩 Purpose: Set up the environment before any code is built.
> 💡 Example: Installing dependencies like Python packages, Node modules, updating Linux packages, etc.

```yaml
install:
  runtime-versions:
    python: 3.9
    nodejs: 14
  commands:
    - echo Installing system packages
    - apt-get update -y
    - apt-get install -y jq
```

**Common Uses:**

* Specify runtime versions (Python, Java, Node.js, Docker, etc.)
* Install system packages (via `apt`, `yum`)
* Set up environment variables
* Validate tools (e.g., `aws --version`)

---

### 🔄 `pre_build:` Phase

> 🧩 Purpose: Do things **before building**, like authentication or preprocessing.
> 💡 Example: Logging in to Docker registries, setting up AWS credentials, testing linting, etc.

```yaml
pre_build:
  commands:
    - echo Logging in to Amazon ECR...
    - aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
    - echo Pre-build done
```

**Common Uses:**

* Docker/ECR login
* Linting
* Secret decryption
* Dependency pre-caching

---

### 🏗️ `build:` Phase

> 🧩 Purpose: This is where the **main build happens**. Compile, transpile, or run test suites.
> 💡 Example: `npm run build`, `mvn package`, `pytest`, or `docker build`.

```yaml
build:
  commands:
    - echo Building the application...
    - npm install
    - npm run build
```

**Common Uses:**

* Compile code
* Run test cases
* Build Docker images
* Minify or bundle assets

---

### ✅ `post_build:` Phase

> 🧩 Purpose: Final steps after the build: pushing artifacts, cleanup, or generating metadata.
> 💡 Example: Docker push, tagging artifacts, notifying Slack, writing to S3.

```yaml
post_build:
  commands:
    - echo Pushing Docker image...
    - docker push <ecr-repo-url>:latest
    - echo Build completed successfully!
```

**Common Uses:**

* Push Docker image to ECR
* Save logs or reports
* Clean temp files
* Notify other systems (SNS, Slack, email)

---

## 💡 Pro Tips for the Exam

| Phase        | Typical Activities                   | Exam-Tricky Detail                                     |
| ------------ | ------------------------------------ | ------------------------------------------------------ |
| `install`    | Setup runtimes, install OS packages  | Can declare multiple runtimes using `runtime-versions` |
| `pre_build`  | Logins, download deps, validation    | Used for ECR auth, `aws configure`, secret fetch       |
| `build`      | Compilation, testing                 | Most resource-intensive, show logs in console          |
| `post_build` | Push artifacts, cleanup, upload logs | Often includes S3 uploads or ECR push                  |

---

### ⚠️ Exam Tips:

* Know all **phases**: `install`, `pre_build`, `build`, `post_build`
* Understand **environment variables** (plaintext or secrets from Parameter Store)
* Output artifacts = build output stored in S3

---

Here’s a detailed real-world example of a `buildspec.yml` file used to build and push a **Dockerized Node.js** application to **Amazon ECR**, with CI/CD best practices built in.

---

## 🧪 Example: `buildspec.yml` for Dockerized Node.js App

### 🗂️ Folder Structure:

```
my-app/
├── Dockerfile
├── app.js
├── package.json
├── buildspec.yml
```

---

### 📄 `buildspec.yml`

```yaml
version: 0.2

env:
  variables:
    IMAGE_REPO_NAME: my-nodejs-app
    IMAGE_TAG: latest
    AWS_REGION: us-east-1

phases:
  install:
    runtime-versions:
      nodejs: 14
    commands:
      - echo Installing source NPM dependencies...
      - npm install

  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com)
      - REPOSITORY_URI=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - echo Repository URI is $REPOSITORY_URI
      - echo Setting image tag as $IMAGE_TAG

  build:
    commands:
      - echo Building Docker image...
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG

  post_build:
    commands:
      - echo Pushing image to Amazon ECR...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions to imagedefinitions.json...
      - |
        printf '[{"name":"%s","imageUri":"%s"}]' $IMAGE_REPO_NAME $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files: 
    - imagedefinitions.json
```

---

### ✅ Key Highlights:

| Section       | Explanation                                                                 |
| ------------- | --------------------------------------------------------------------------- |
| `env:`        | Defines environment variables used in all phases.                           |
| `install:`    | Installs project dependencies (`npm install`).                              |
| `pre_build:`  | Logs into ECR and sets Docker repo variables dynamically.                   |
| `build:`      | Builds and tags the Docker image.                                           |
| `post_build:` | Pushes the image to ECR and creates `imagedefinitions.json` for CodeDeploy. |
| `artifacts:`  | `imagedefinitions.json` is required if you're using ECS in CodePipeline.    |

---

### 🔑 Exam Tips

| Concept                 | Exam Clue/Twist                                                               |
| ----------------------- | ----------------------------------------------------------------------------- |
| `imagedefinitions.json` | Required when deploying to ECS via CodePipeline using CodeDeploy.             |
| Auth to ECR             | Must use `aws ecr get-login-password` (especially with `Fargate` or EKS/ECS). |
| Phases separation       | Understand what runs where. Build failures often stem from the wrong phase.   |
| `env` variables         | Can be overwritten in CodeBuild project settings or passed from CodePipeline. |

---

## 🚀 3. CodeDeploy (Deployment Tool)

---

### 🔹 What is CodeDeploy?

* Automates **app deployments** to:

  * **EC2**, **Lambda**, or **On-prem servers**
  * **Auto Scaling Groups**
* Supports **in-place** and **Blue/Green** deployments

---

### 🧾 `appspec.yml` — THE Deployment Blueprint

This file tells CodeDeploy **what to copy**, and **what scripts to run** before/after deployment.

---

### ✅ Sample for EC2:

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/html

hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 180
  AfterInstall:
    - location: scripts/after_install.sh
  ApplicationStart:
    - location: scripts/start_server.sh
  ValidateService:
    - location: scripts/validate_service.sh
```

> Place this in the **root of your deployment artifact (usually a zip)**.

---

### ✅ Sample for Lambda:

```yaml
version: 0.0

Resources:
  - myFunction:
      Type: AWS::Lambda::Function
      Properties:
        Name: my-lambda
        Alias: live

Hooks:
  - BeforeAllowTraffic: test-hook-func
  - AfterAllowTraffic: cleanup-func
```

---

### ⚠️ Exam Tips:

* **Understand the difference** between:

  * `BeforeInstall` vs `AfterInstall` vs `ApplicationStart`
  * EC2 (Linux) and Lambda (with hooks)
* **Blue/Green deployments are supported for Lambda** out-of-the-box.

---

## 🛠️ 4. CodePipeline (The Glue for CI/CD)

---

### 🔹 What is CodePipeline?

* A visual pipeline builder to connect all CI/CD stages:

  * **Source → Build → Test → Deploy**
* Supports:

  * AWS-native tools (CodeCommit, CodeBuild, CodeDeploy)
  * 3rd-party (GitHub, Jenkins, etc.)

---

### ✅ How to Trigger Pipeline on Code Push?

1. When using **CodeCommit**, CodePipeline automatically triggers on a push.
2. When using **GitHub**, you must:

   * Set up a webhook.
   * Or use **EventBridge rule** for trigger (GitHub Enterprise only).

---

### 🔁 How It All Connects

```
[CodeCommit] ──Push──▶ [CodePipeline]
                        │
                        ▼
                  [CodeBuild Stage]
                        │
                        ▼
                  [CodeDeploy Stage]
                        │
                        ▼
                    [EC2 / Lambda]
```

---

### 📄 JSON-style Pipeline Structure

Example:

```json
{
  "pipeline": {
    "name": "MyPipeline",
    "roleArn": "arn:aws:iam::123:role/AWSCodePipelineServiceRole",
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeCommit",
              "version": "1"
            },
            "outputArtifacts": ["SourceArtifact"],
            "configuration": {
              "RepositoryName": "my-repo",
              "BranchName": "main"
            }
          }
        ]
      }
    ]
  }
}
```

---

## 🔐 IAM Role Structure (Very Important for Exam)

| Service      | Role Name                 | Permissions Needed                         |
| ------------ | ------------------------- | ------------------------------------------ |
| CodeBuild    | `CodeBuildServiceRole`    | S3, logs, ECR, Parameter Store (optional)  |
| CodeDeploy   | `CodeDeployServiceRole`   | EC2 or Lambda access                       |
| CodePipeline | `CodePipelineServiceRole` | Assume above roles, read/write to S3, logs |

Each service assumes the right IAM role to **only do its job**, following **least privilege**.

---

**real-world end-to-end CI/CD setup using:**

✅ **CodeCommit** (Source repo)
✅ **CodeBuild** (Build and create artifacts)
✅ **CodeDeploy** (Deploy to EC2)
✅ **CodePipeline** (Orchestrates everything)

---

## 🎯 Overview

* App files are stored in **CodeCommit**.
* When you push code, **CodePipeline** is triggered.
* **CodeBuild** uses `buildspec.yml` to build and package.
* **CodeDeploy** deploys the app to EC2 using `appspec.yml`.

---

## 🧾 1. `buildspec.yml` – CodeBuild Config

```yaml
version: 0.2

phases:
  install:
    commands:
      - echo Installing...
  build:
    commands:
      - echo Build started...
      - mkdir -p output
      - cp index.html output/
  post_build:
    commands:
      - echo Build completed

artifacts:
  files:
    - '**/*'
  base-directory: output
```

---

## 📦 2. `appspec.yml` – CodeDeploy Config

```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /var/www/html
hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 300
      runas: root
  AfterInstall:
    - location: scripts/after_install.sh
      timeout: 300
      runas: root
```

### 🔧 Sample Hook Scripts

**`scripts/before_install.sh`**:

```bash
#!/bin/bash
echo "Stopping old server..."
sudo systemctl stop httpd
```

**`scripts/after_install.sh`**:

```bash
#!/bin/bash
echo "Starting web server..."
sudo systemctl start httpd
```

---

## 🐙 3. CodeCommit Setup

Use AWS CLI to create a repo:

```bash
aws codecommit create-repository --repository-name MyWebApp
```

Push your code (first-time setup):

```bash
git init
git remote add origin https://git-codecommit.<region>.amazonaws.com/v1/repos/MyWebApp
git add .
git commit -m "Initial commit"
git push origin main
```

---

## 🏗️ 4. CodeBuild Project (AWS Console or YAML)

Basic config:

* Source: CodeCommit
* Buildspec file: `buildspec.yml`
* Artifacts: `output/`
* Environment: Standard Ubuntu, managed image

IAM Role **must** include:

* `codecommit:GitPull`
* `s3:*` for your artifact bucket

---

## 🚀 5. CodeDeploy Setup

* EC2 instances should have **CodeDeploy Agent installed**
* IAM Role on EC2: `AmazonEC2RoleforAWSCodeDeploy`
* Deployment group must be attached to a tag or Auto Scaling group

---

## 🔄 6. CodePipeline – Full Integration

You can create this from the AWS Console (preferred for beginners), or use CloudFormation/IaC.

Pipeline flow:

* **Source Stage**: CodeCommit → triggers on push
* **Build Stage**: CodeBuild → builds using `buildspec.yml`
* **Deploy Stage**: CodeDeploy → deploys using `appspec.yml`

---

---

## 🧩 7. CodePipeline Configuration (Console / YAML / CloudFormation)

Here’s how you can **configure CodePipeline** in real projects:

---

### ✅ **1. CodePipeline – YAML Example (CloudFormation Style)**

```yaml
Resources:
  MyPipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      RoleArn: arn:aws:iam::123456789012:role/CodePipelineServiceRole
      ArtifactStore:
        Type: S3
        Location: my-codepipeline-artifact-bucket
      Stages:
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: AWS
                Provider: CodeCommit
                Version: 1
              OutputArtifacts:
                - Name: SourceOutput
              Configuration:
                RepositoryName: MyWebApp
                BranchName: main
        - Name: Build
          Actions:
            - Name: BuildAction
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: 1
              InputArtifacts:
                - Name: SourceOutput
              OutputArtifacts:
                - Name: BuildOutput
              Configuration:
                ProjectName: MyWebAppBuild
        - Name: Deploy
          Actions:
            - Name: DeployAction
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: CodeDeploy
                Version: 1
              InputArtifacts:
                - Name: BuildOutput
              Configuration:
                ApplicationName: MyWebApp
                DeploymentGroupName: MyWebAppDG
```

---

### ⚙️ 2. How to Create This in Console

**Step-by-step via Console:**

1. **Step 1 – Source Stage**

   * Source provider: CodeCommit
   * Repo: `MyWebApp`, Branch: `main`

2. **Step 2 – Build Stage**

   * Provider: CodeBuild
   * Project: `MyWebAppBuild`
   * Artifact output: S3 bucket

3. **Step 3 – Deploy Stage**

   * Provider: CodeDeploy
   * Application name: `MyWebApp`
   * Deployment group: `MyWebAppDG`

4. **IAM Role**

   * Use an IAM role with the following:

     * `codepipeline:*`
     * `codebuild:*`
     * `codedeploy:*`
     * `s3:*`
     * `codecommit:*`

---

## 🎯 Triggering the Pipeline Automatically

You **don't need to configure anything manually** to trigger CodePipeline on a code push if:

* CodePipeline uses **CodeCommit** as the source.
* It **automatically sets up EventBridge events** to trigger pipeline.

✅ **Exam Tip**:
You **do not need to manually configure** EventBridge or CloudWatch events if you're using CodeCommit as the source. CodePipeline sets this up for you.

---

### 🛡️ Bonus Exam Notes

| Feature         | Notes                                                                 |
| --------------- | --------------------------------------------------------------------- |
| `buildspec.yml` | Mandatory for CodeBuild unless configured inline. Know all phases.    |
| `appspec.yml`   | Mandatory for CodeDeploy. Know hook order and failure behaviors.      |
| Artifacts       | Stored in S3. Use CodePipeline’s S3 artifact bucket.                  |
| IAM             | One role per service: CodeBuild, CodeDeploy, Pipeline need own roles. |
| Triggers        | CodePipeline triggers automatically from CodeCommit (no EventBridge). |
| Blue/Green      | Use with **CodeDeploy + ALB**, not just EC2.                          |

---


## 🔁 Trigger Flow

1. Push code to CodeCommit.
2. CodePipeline detects change and triggers.
3. CodeBuild runs, packages files, outputs to S3.
4. CodeDeploy pulls artifact from S3 and deploys to EC2.

---

## ✅ Final Notes (Exam & Real Use Tips)

| Service      | Exam Tip                                                              |
| ------------ | --------------------------------------------------------------------- |
| CodeCommit   | Git-based. IAM auth (HTTPS or SSH). EventBridge triggers pipelines.   |
| CodeBuild    | `buildspec.yml`, phases, store in S3. Add runtime, env variables.     |
| CodeDeploy   | Understand `appspec.yml`, lifecycle hooks, in-place vs blue/green.    |
| CodePipeline | Orchestrates stages. Must define roles for each stage. Auto triggers. |

---

## 💡 Exam-Specific Summary

| Concept                 | Why It Matters on Exam                               |
| ----------------------- | ---------------------------------------------------- |
| `buildspec.yml`         | Know structure, phases, environment variables        |
| `appspec.yml`           | Know hooks and deployment types (EC2 vs Lambda)      |
| CodePipeline triggering | Know auto-trigger methods (especially for Git repos) |
| Deployment types        | In-place vs Blue/Green differences                   |
| IAM separation          | Each service has its own role, with scoped access    |
| Integration order       | CodeCommit → CodeBuild → CodeDeploy → CodePipeline   |

---

