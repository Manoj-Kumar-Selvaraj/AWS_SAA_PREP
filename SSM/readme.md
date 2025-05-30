---

# AWS Systems Manager CLI Hands-On Guide

---

## Prerequisites:

* AWS CLI installed and configured (`aws configure`)
* IAM user/role with these permissions:

```json
{
  "Effect": "Allow",
  "Action": [
    "ssm:PutParameter",
    "ssm:GetParameter",
    "ssm:GetParameters",
    "ssm:StartSession",
    "ssm:SendCommand",
    "ssm:DescribeInstanceInformation"
  ],
  "Resource": "*"
}
```

* At least **one EC2 instance** with:

  * SSM Agent installed and running (Amazon Linux, Ubuntu, Windows AMIs usually have it)
  * IAM role attached with `AmazonSSMManagedInstanceCore` policy

---

# Verify EC2 is Ready for SSM

### 1.1 Check if SSM Agent is installed & running on your EC2

Run this **on the EC2 instance** (if you have SSH access for now):

* For Amazon Linux/Ubuntu:

```bash
# Check if agent is running
sudo systemctl status amazon-ssm-agent
```

If not installed, install it:

* Amazon Linux 2:

```bash
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
```

* Ubuntu:

```bash
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
```

---

### 1.2 Attach IAM Role to EC2 with SSM permissions

Your EC2 instance **must have an IAM role attached** with this policy:

```json
{
  "Effect": "Allow",
  "Action": [
    "ssm:DescribeInstanceInformation",
    "ssm:GetCommandInvocation",
    "ssm:SendCommand",
    "ssm:StartSession",
    "ssm:DescribeSessions",
    "ssm:GetParameters",
    "ssm:GetParameter"
  ],
  "Resource": "*"
}
```

Or simply attach AWS managed policy:

**AmazonSSMManagedInstanceCore**

---

## 1️⃣ Create a Parameter (String or SecureString)

### Create a plain string parameter:

```bash
aws ssm put-parameter --name "/dev/my-app/config" --value "HelloWorld" --type String
```

### Create a SecureString (encrypted):

```bash
aws ssm put-parameter --name "/dev/my-app/dbpassword" --value "MySecretPass123" --type SecureString
```

---

## 2️⃣ Retrieve a Parameter

### Get plain string:

```bash
aws ssm get-parameter --name "/dev/my-app/config"
```

### Get SecureString (decrypted):

```bash
aws ssm get-parameter --name "/dev/my-app/dbpassword" --with-decryption
```

---

## 3️⃣ List Parameters (optional)

```bash
aws ssm describe-parameters
```

---

## 4️⃣ Start a Session with EC2 (Session Manager)

Make sure your EC2 instance is online and registered with SSM.

### List instances managed by SSM:

```bash
aws ssm describe-instance-information
```

Find your instance ID from the list.

### Start a session with the instance:

```bash
aws ssm start-session --target i-0123456789abcdef0
```

You will get an interactive shell prompt inside the EC2 instance.

---

## 5️⃣ Run a Command Remotely (Run Command)

Example: Run `uptime` on EC2 instance:

```bash
aws ssm send-command \
  --instance-ids "i-0123456789abcdef0" \
  --document-name "AWS-RunShellScript" \
  --comment "Check uptime" \
  --parameters commands=["uptime"]
```

To get the command output, note the `CommandId` from response and run:

```bash
aws ssm list-command-invocations --command-id <CommandId> --details
```

---

## Summary of What You Did

| Task                                 | AWS CLI Command       |
| ------------------------------------ | --------------------- |
| Store parameter (plain & encrypted)  | `put-parameter`       |
| Retrieve parameter (with decryption) | `get-parameter`       |
| List parameters                      | `describe-parameters` |
| Open shell on EC2 without SSH keys   | `start-session`       |
| Run script remotely on EC2           | `send-command`        |

---

