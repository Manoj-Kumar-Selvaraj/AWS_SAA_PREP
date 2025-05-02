### ✅ Issue: Warning from empty `filter {}` block in `aws_s3_bucket_lifecycle_configuration`

**Terraform Warning Message:**
```
Warning: Invalid Attribute Combination

  with aws_s3_bucket_lifecycle_configuration.athena_test_block_lifecycle_config,
  on main.tf line 56, in resource "aws_s3_bucket_lifecycle_configuration" "athena_test_block_lifecycle_config":
  56:     filter {}

No attribute specified when one (and only one) of
[rule[0].filter[0].prefix.<.object_size_greater_than,rule[0].filter[0].prefix.<.object_size_less_than,rule[0].filter[0].prefix.<.and,rule[0].filter[0].prefix.<.tag]
is required

This will be an error in a future version of the provider.
```

---

### 🔍 Root Cause:
Using an empty `filter {}` block is deprecated. The AWS provider requires **at least one attribute** inside the `filter` block (e.g., `prefix`, `tag`, or `and`).

---

### ✅ Fix:

**Before:**
```hcl
filter {}
```

**After:**
```hcl
filter {
  prefix = ""
}
```

> This applies the lifecycle rule to **all objects** in the bucket.

---

### 💡 Notes:
- This is a **forward-compatible fix**, ensuring your Terraform code continues to work with future AWS provider versions.
- Always check provider documentation when encountering changes in behavior or validation rules.

### Error: creating EC2 VPC: operation error EC2: CreateVpc, https response error StatusCode: 400, RequestID: 17aecadb-1294-4575-a945-6f82550952e2, api error InvalidParameterValue: The allocation size is too big for the pool.
│ 
│   with aws_vpc.Transfer_Fam_VPC,
│   on main.tf line 223, in resource "aws_vpc" "Transfer_Fam_VPC":
│  223: resource "aws_vpc" "Transfer_Fam_VPC" {

🔍 Root Cause:
A /16 block was requested from an IPAM pool that only defines a /8 without sub-pools. IPAM doesn’t automatically split address ranges unless explicitly configured.

✅ Fix:
Create a child IPAM pool from the parent /8 pool.

Allocate the /16 block from the child pool.

# AWS ACM SSL Certificate Validation - CNAME Record Troubleshooting

## Overview
This guide outlines the steps and troubleshooting techniques used to validate an SSL certificate through AWS ACM (AWS Certificate Manager) for the domain `athena.manoj-techworks.site`. The issue involved properly configuring DNS records in Namecheap and AWS Route 53 to allow for the successful validation of the ACM certificate.

## Issue:
The SSL certificate for `athena.manoj-techworks.site` was not being validated in AWS ACM despite adding the CNAME validation record in the hosted zone. DNS records appeared to be set correctly, but validation was still pending.

## Solution

### Step 1: Check ACM Validation Record
AWS ACM provides a CNAME record to be added to your DNS settings for domain validation. The CNAME record consists of two parts:
- **Host Value**: This is typically a unique string provided by AWS, such as `_0c7036581e597b9b7349424cf5dc8bfb.athena.manoj-techworks.site`.
- **Value**: This is the value to point the CNAME record to, such as `_255856d082d65e54fa9aeeb9ad801ef3.xlfgrmvvlj.acm-validations.aws.`

### Step 2: Add CNAME Record in Namecheap
1. Log into your Namecheap account.
2. Go to **Domain List** and select your domain (`manoj-techworks.site`).
3. Under the **Advanced DNS** settings, add the provided CNAME record.
    - **Host**: `_0c7036581e597b9b7349424cf5dc8bfb.athena.manoj-techworks.site`
    - **Value**: `_255856d082d65e54fa9aeeb9ad801ef3.xlfgrmvvlj.acm-validations.aws.`
    - **TTL**: 300 seconds (or as per your preference).

### Step 3: Add the Correct NS Records in Route 53
Ensure that the domain is correctly pointed to AWS Route 53 name servers:
1. Go to your **AWS Route 53** hosted zone for `athena.manoj-techworks.site`.
2. Ensure you have added the following **NS records** in the Namecheap DNS settings:
    - `ns-1092.awsdns-08.org.`
    - `ns-1002.awsdns-61.net.`
    - `ns-56.awsdns-07.com.`
    - `ns-1595.awsdns-07.co.uk.`

### Step 4: Wait for DNS Propagation
After configuring the DNS records, it may take some time for the changes to propagate. This can take anywhere from a few minutes to several hours, depending on the DNS cache and TTL settings.

You can check the propagation status using tools like [WhatsMyDNS](https://www.whatsmydns.net/) to see if the CNAME record is being resolved across different locations.

### Step 5: Validate the Certificate in AWS ACM
Once the DNS propagation is complete, return to the **AWS Certificate Manager** (ACM) console.
- Check if the certificate status changes from **Pending validation** to **Issued**.
- If the certificate still shows **Pending validation**, ensure all the DNS records are correctly set and propagated.

### Troubleshooting Tips:
1. **DNS Propagation Delay**: DNS changes can take time. If the validation is still pending after several hours, wait for a few more hours or check with a DNS propagation tool.
2. **Verify Record Accuracy**: Double-check that the host and value for the CNAME record exactly match the information provided in the ACM console.

## Conclusion
This process will allow you to successfully validate an SSL certificate in AWS ACM by adding the correct DNS records in your domain registrar (Namecheap) and configuring the hosted zone in AWS Route 53.

Once the validation is successful, your certificate will be issued and can be used for securing your domain.

---

### Notes:
- If the validation is still pending after a long wait, it might be worth reviewing the DNS setup to ensure there are no conflicts or misconfigurations.
- Keep in mind that DNS records might not appear to update immediately after modification; refreshing the page in your DNS management console (e.g., Namecheap) may help show the most up-to-date values.
