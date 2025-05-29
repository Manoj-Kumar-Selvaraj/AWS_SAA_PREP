# 1. **AWS Cognito**

### What is it?

* Managed service for **user sign-up, sign-in, and access control** to your web/mobile apps.
* Supports **user pools** (user directory) and **identity pools** (federated identities, e.g., login with Google, Facebook).
* Provides authentication, authorization, and user management.

### Key Concepts

* **User Pool**: User directory with sign-up/sign-in, MFA, password policies.
* **Identity Pool**: Provides temporary AWS credentials to users authenticated via user pools or federated providers.
* Supports **OAuth 2.0, SAML**, social logins.

### Example Use Case

* Mobile app user logs in via Cognito user pool.
* App gets AWS credentials from Cognito identity pool.
* User accesses AWS resources securely.

### Basic CLI to create a user pool

```bash
aws cognito-idp create-user-pool --pool-name MyUserPool --region us-east-1
```

### Developer Exam Tips

* Know difference between **User Pools** and **Identity Pools**.
* Understand how Cognito integrates with API Gateway/Lambda.
* Understand user authentication flow basics.

---

# 2. **AWS Secrets Manager**

### What is it?

* Securely store and manage secrets like **database passwords, API keys, OAuth tokens**.
* Supports **automatic rotation** of secrets with Lambda functions.
* Secrets can be retrieved programmatically with fine-grained IAM permissions.

### Why Use It?

* Avoid hardcoding sensitive info in code.
* Automatic secret rotation helps maintain security best practices.

### Example CLI to create a secret

```bash
aws secretsmanager create-secret --name MyAppSecret --secret-string '{"username":"admin","password":"MyStrongPass123"}' --region us-east-1
```

### How to retrieve secret (CLI)

```bash
aws secretsmanager get-secret-value --secret-id MyAppSecret --region us-east-1
```

### Developer Exam Tips

* Understand basics of storing, retrieving, and rotating secrets.
* Know integration points: Lambda, RDS, EC2, ECS.

---

# 3. **AWS Certificate Manager (ACM)**

### What is it?

* Managed service to **provision, manage, and deploy SSL/TLS certificates** for your domains.
* Certificates are free when used with AWS services (ELB, CloudFront, API Gateway).
* Simplifies SSL cert lifecycle management.

### Important Concepts

* Public certificates (internet-facing domains)
* Private certificates (for internal domains using AWS Private CA)
* Certificates can be requested via CLI or Console.

### Example CLI to request a certificate (public)

```bash
aws acm request-certificate --domain-name example.com --validation-method DNS --region us-east-1
```

### Developer Exam Tips

* Know how ACM is used with ELB, API Gateway for HTTPS.
* Understand DNS validation vs email validation.
* Know basics about private CA (not required in detail).

---

# 4. **AWS Key Management Service (KMS)**

### What is it?

* Managed service to create and control **encryption keys** used to encrypt data across AWS services and your apps.
* Supports **symmetric** and **asymmetric** CMKs (Customer Master Keys).
* Integrates with services like S3, EBS, RDS, Lambda for data encryption.

### Key Features

* Create, rotate, disable, and audit keys.
* Use keys to encrypt/decrypt data or sign/verify messages.
* IAM policies + Key policies control usage.

### Example CLI to create a CMK

```bash
aws kms create-key --description "My KMS Key" --region us-east-1
```

### Example to encrypt data with KMS key

```bash
aws kms encrypt --key-id alias/MyKey --plaintext "Hello World" --region us-east-1 --query CiphertextBlob --output text
```

### Developer Exam Tips

* Understand KMS key policies vs IAM policies.
* Know integration with services (e.g., S3 bucket encryption).
* Understand symmetric vs asymmetric keys at a high level.

---
