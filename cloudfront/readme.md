---

## ✅ **Amazon CloudFront – Overview**

**CloudFront** is Amazon’s **Content Delivery Network (CDN)** that delivers your content (HTML, CSS, JavaScript, images, videos, APIs) with low latency and high transfer speeds using a network of **edge locations**.

---

## 🔧 **Core Features You Should Know**

| Feature            Description                                                                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Edge Locations**      | Data centers around the world where CloudFront caches content.                                                                  |
| **Origin**              | The source of the content (e.g., S3 bucket, EC2, or even non-AWS servers).                                                      |
| **Distribution**        | The configuration setup that defines how CloudFront delivers content. Two types: Web and RTMP (RTMP is legacy).                 |
| **Caching**             | CloudFront caches content at edge locations to reduce load on origin and improve speed.                                         |
| **TTL (Time to Live)**  | How long content stays cached before being revalidated or expired.                                                              |
| **Invalidation**        | You can manually remove cached content using invalidation requests.                                                             |
| **Signed URLs/Cookies** | Used to restrict access to private content (e.g., paid videos, files).                                                          |
| **HTTPS Support**       | CloudFront supports HTTPS for secure content delivery using ACM or custom SSL certificates.                                     |
| **Lambda\@Edge**        | Run custom code (Node.js or Python) at CloudFront edge locations for advanced use cases (e.g., header manipulation, redirects). |

---

## 🧠 **Exam-Relevant Use Cases**

1. **Serving static website content** from S3 via CloudFront.
2. **Improving API performance** when used with API Gateway or custom backend services.
3. **Restricting access** to content using **signed URLs or cookies**.
4. **Improving security and speed** using HTTPS, geo-restriction, or WAF integration.
5. **Customizing responses** using **Lambda\@Edge**.

---

## 📘 Sample Questions (Exam Style)

1. **Q:** You need to deliver static assets globally with low latency. Which AWS service should you use?
   **A:** CloudFront

2. **Q:** How can you invalidate a cached object in CloudFront?
   **A:** By creating an invalidation request.

3. **Q:** Which feature allows custom logic at CloudFront edge locations?
   **A:** Lambda\@Edge

---

## 📌 Pro Tips for Exam

* Know **how CloudFront integrates with S3** and **API Gateway**.
* Understand **signed URLs vs. signed cookies**.
* Be clear on **origin failover**, i.e., what happens if the primary origin fails.
* Understand **how TTL affects caching and performance**.
* Remember **CloudFront can deliver both dynamic and static content**.

---
