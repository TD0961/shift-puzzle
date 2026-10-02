# Cloudflare Pages Static Deployment Guide — Shift Puzzle

This guide documents the exact steps to deploy the static Shift Puzzle landing and download website to **Cloudflare Pages** (Free Tier) with zero server, zero database, and zero ongoing paid hosting costs.

---

## Architecture Overview

```
                      +-----------------------------+
                      |   Cloudflare Pages (Edge)   |
                      |   Static HTML / JS / Assets |
                      +--------------+--------------+
                                     |
               +---------------------+---------------------+
               |                                           |
               v                                           v
    [ Visitors / Social Ads ]                 [ Direct APK Download ]
   tiktok / youtube / qr params              External Object Storage (R2/S3)
   Logged in browser localStorage                51 MB release artifact
   (No PII collected, zero cookies)            (Never routes through ads)
```

### Key Architectural Separation:
1. **Website Static Host:** Cloudflare Pages hosts the compiled HTML, CSS, client-side JS bundles, and preview images (~1 MB compressed).
2. **APK File Storage:** The 51 MB release APK (`app-release.apk`) should be hosted on external object storage (such as Cloudflare R2, AWS S3, or GitHub Releases) configured via `NEXT_PUBLIC_APK_URL`. This avoids bloating edge static deploys and allows independent versioning.
3. **Attribution Separation:** Website campaign attribution (`?source=tiktok`) is stored locally in the visitor's browser (`localStorage`). It is **never** claimed or transmitted to the sideloaded Android app because direct APK installs lack an app store install referrer.

---

## 1. Cloudflare Pages Project Settings

When creating a new Cloudflare Pages project from the Git repository:

| Setting | Value |
|---|---|
| **Root directory** | `website` |
| **Framework preset** | `None` / `Next.js (Static Export)` |
| **Build command** | `npm run build` |
| **Build output directory** | `out` |
| **Node.js Version** | `20` or higher (`NODE_VERSION = 20`) |

---

## 2. Environment Variables Configuration

Configure these in Cloudflare Pages dashboard (**Settings > Environment variables > Production**):

### Required for Production Launch:
- `NEXT_PUBLIC_SITE_URL`: Canonical URL where the site is served.
  - Initial staging: `https://<project-name>.pages.dev`
  - Production custom domain: `https://shiftpuzzle.app`
- `NEXT_PUBLIC_APK_URL`: Direct link to your hosted release APK on Cloudflare R2 / AWS S3 / GitHub Releases.
  - Example: `https://pub-your-bucket.r2.dev/shift-puzzle-v1.0.0.apk`

### Optional Variables:
- `NEXT_PUBLIC_ADSTERRA_SMARTLINK_URL`: Your verified Adsterra SmartLink URL.
  - *Leave unset until you receive your production URL from Adsterra. If absent, the sponsor section is completely omitted from the rendered page.*
- `NEXT_PUBLIC_ANALYTICS_ENDPOINT`: Optional HTTP telemetry endpoint for tracking web funnel conversion (`landing_page_view`, `download_clicked`, `smartlink_clicked`).
- `NEXT_PUBLIC_CONTACT_EMAIL`: Public support email (default: `support@shiftpuzzle.app`).
- Social Media Links: `NEXT_PUBLIC_TIKTOK_URL`, `NEXT_PUBLIC_YOUTUBE_URL`, `NEXT_PUBLIC_INSTAGRAM_URL`, `NEXT_PUBLIC_FACEBOOK_URL`, `NEXT_PUBLIC_TELEGRAM_URL`.

---

## 3. Deployment Methods

### Option A: Automatic Git Deploy (Recommended)
1. Push your repository to GitHub or GitLab.
2. In the Cloudflare Dashboard, navigate to **Workers & Pages** > **Create application** > **Pages** > **Connect to Git**.
3. Select the repository and configure:
   - Root directory: `website`
   - Build command: `npm run build`
   - Output directory: `out`
4. Add the environment variables specified above.
5. Click **Save and Deploy**.

### Option B: Direct Upload via Wrangler CLI
You can deploy without Git integration using Cloudflare's `wrangler` CLI:
```bash
cd website
npm run build
npx wrangler pages deploy out --project-name shift-puzzle
```

---

## 4. Custom Domain Setup (Post-Deployment)
Once deployed to `https://<your-project>.pages.dev`:
1. In Cloudflare Pages, go to **Custom domains**.
2. Click **Set up a custom domain**.
3. Enter your domain (e.g. `shiftpuzzle.app`).
4. Update `NEXT_PUBLIC_SITE_URL` in Cloudflare Pages environment variables to match your custom domain.
5. Trigger a rebuild so `sitemap.xml`, `robots.txt`, and Open Graph tags generate with the production URL.

---

## 5. APK Sideload Hosting on Cloudflare R2 (Free Tier)
Cloudflare R2 provides 10 GB/month free storage with **$0 egress fees**, making it ideal for hosting the 51 MB APK:
1. In Cloudflare Dashboard, go to **R2** > **Create bucket** (e.g. `shift-puzzle-releases`).
2. Upload `app-release.apk`.
3. In Bucket Settings, enable **Public Access** or attach a custom subdomain (e.g. `download.shiftpuzzle.app`).
4. Copy the public file URL and set `NEXT_PUBLIC_APK_URL` in Cloudflare Pages.

---

## 6. Verification Checklist
After deployment:
- [ ] Homepage loads cleanly at canonical domain without layout shift.
- [ ] "DOWNLOAD FOR ANDROID" downloads the APK directly from `NEXT_PUBLIC_APK_URL`.
- [ ] No advertising or SmartLink appears on the primary download button.
- [ ] If SmartLink is configured, the sponsor section appears separately with clear labeling.
- [ ] Visiting `/download/?source=tiktok` logs the source to browser `localStorage` without collecting PII.
- [ ] QR code on `/download` points to `${NEXT_PUBLIC_SITE_URL}/download/?source=qr`.
- [ ] `/privacy/` renders the complete privacy disclosure.
- [ ] `/robots.txt` and `/sitemap.xml` reference the configured canonical URL.
