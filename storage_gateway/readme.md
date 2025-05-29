**AWS Storage Gateway** is a **hybrid cloud storage service** that connects your **on-premises environment** to **AWS cloud storage**. It allows you to **extend your local data center’s storage to AWS**, giving you seamless and secure integration between on-prem and cloud.

---

## 🔧 Types of AWS Storage Gateway

There are **three types**, each designed for specific use cases:

### 1. **File Gateway**

* 🗂️ Stores files in **Amazon S3** as objects.
* Appears to your on-prem system as an **NFS** or **SMB** file share.
* Common Use Case: Backup, archiving, file sharing.

### 2. **Volume Gateway**

* 📦 Stores data locally, and asynchronously backs up to S3 as **EBS snapshots**.
* Two modes:

  * **Cached volumes**: Store frequently accessed data locally, rest in S3.
  * **Stored volumes**: Store all data locally, back up to S3.
* Common Use Case: On-prem apps needing low-latency access + cloud backup.

### 3. **Tape Gateway**

* 🎞️ Replaces physical tape backups with **virtual tape library (VTL)** in AWS.
* Data is stored in **S3** and archived to **Glacier**.
* Common Use Case: Migrate legacy tape-based backup systems to cloud.

---

## 🧠 Key Points for the AWS Exams

| Feature        | Notes                                                    |
| -------------- | -------------------------------------------------------- |
| Hybrid Storage | Extends on-prem storage to AWS                           |
| Integration    | Connects with S3, Glacier, EBS                           |
| Use Cases      | Backup, disaster recovery, data migration                |
| Appliance      | Runs as a **VM**, **hardware appliance**, or **EC2 AMI** |
| Caching        | Provides local cache for frequently used data            |

---

## 🎯 Why It Matters

* Helps companies **migrate to the cloud gradually**.
* Useful for **on-prem systems** that can’t fully move to cloud yet.
* Keeps **latency low** while using scalable AWS storage in the background.

---
