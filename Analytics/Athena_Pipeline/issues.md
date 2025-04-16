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