# Custom Domain Setup for yournftree.com

This guide explains how to point **`yournftree.com`** directly to GitHub Pages so the browser address bar keeps showing `yournftree.com` (and `https://yournftree.com`) rather than redirecting to `https://nftree721.github.io/`.

---

## Why the URL Was Changing

Your domain was previously configured with **Domain Forwarding** (`HTTP 301 Moved Permanently`). A forwarding rule instructs the browser to load `https://nftree721.github.io/`, changing the address bar. 

To keep your custom domain in the address bar, GitHub Pages needs to serve the site natively using custom DNS records and GitHub's Custom Domain feature.

---

## Step 1: Remove Forwarding & Add DNS Records in Registrar

Log in to your domain registrar (e.g., **Squarespace Domains** / **Google Domains**):

1. Go to **Domains** -> Select **`yournftree.com`** -> **DNS**.
2. **Remove Domain Forwarding:** Delete the existing forwarding/redirect rule pointing to `nftree721.github.io`.
3. **Add Custom DNS Records:**
   Under **Custom Records**, configure the following:

   | Record Type | Host / Name | Target / Value / Points to | TTL |
   | :--- | :--- | :--- | :--- |
   | **A** | `@` (or leave empty) | `185.199.108.153` | Default / 1 hour |
   | **A** | `@` (or leave empty) | `185.199.109.153` | Default / 1 hour |
   | **A** | `@` (or leave empty) | `185.199.110.153` | Default / 1 hour |
   | **A** | `@` (or leave empty) | `185.199.111.153` | Default / 1 hour |
   | **CNAME** | `www` | `nftree721.github.io.` | Default / 1 hour |

> **Note:** The 4 `A` records point your apex domain (`yournftree.com`) directly to GitHub Pages' anycast servers. The `CNAME` ensures `www.yournftree.com` also routes correctly.

---

## Step 2: Configure Custom Domain in GitHub

You can do this using either of the two methods below:

### Method A: Repository `CNAME` File (Recommended)
1. Add a file named `CNAME` at the root of this repository.
2. The file should contain a single line:
   ```text
   yournftree.com
   ```
3. Commit and push the file to the `main` branch.

### Method B: GitHub Web Interface
1. Go to your repository: [nftree721/nftree721.github.io](https://github.com/nftree721/nftree721.github.io).
2. Click **Settings** (top tab) -> **Pages** (left sidebar under *Code and automation*).
3. Under **Custom domain**, type:
   ```text
   yournftree.com
   ```
4. Click **Save**.

---

## Step 3: Enforce HTTPS

1. Allow 5–30 minutes for DNS records to propagate worldwide.
2. GitHub Pages will automatically request and issue a free TLS/SSL certificate via Let's Encrypt.
3. Once the certificate is issued, go to **Settings** -> **Pages** in GitHub.
4. Check the box for **"Enforce HTTPS"**.

---

## Verification & Troubleshooting

To verify that DNS records have taken effect from your terminal:

```bash
# Check apex domain A records
dig yournftree.com +short

# Check www CNAME record
dig www.yournftree.com +short
```

Expected output for `dig yournftree.com +short`:
```text
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

Once DNS is propagated and HTTPS is enforced, visiting `http://yournftree.com`, `https://yournftree.com`, or `www.yournftree.com` will serve the site with `yournftree.com` displayed in the browser bar.
