# Phase 3 Quick Start Guide

**For rapid reference during implementation**

---

## 1-Minute Summary

**What:** Analytics (Plausible), Email leads (Formspree), CI/CD (GitHub Actions), Image SEO (rename script), Backup (S3)

**When:** Jun 1-Jul 15 (three 2-week sprints)

**Cost:** ~€0.50/month (AWS S3 storage only)

**Status:** Complete design doc + all code ready to integrate

---

## Files Created Today (26 May)

| File | Purpose | Size |
|------|---------|------|
| `phase3-decisions.md` | Architecture decisions (7 components) | 8KB |
| `PHASE3-MASTER-PLAN.md` | Complete roadmap + checklist | 25KB |
| `SPRINT1-SETUP.md` | Analytics + Email implementation | 18KB |
| `SPRINT2-SETUP.md` | CI/CD + Image + Backup setup | 22KB |
| `js/analytics-sentry.js` | Plausible + Sentry init code | 4KB |
| `js/email-form-modal.js` | Formspree modal + form logic | 12KB |
| `css/email-modal.css` | Modal styles (responsive) | 6KB |
| `.github/workflows/deploy.yml` | GitHub Actions CI/CD | 15KB |
| `scripts/rename-images.ps1` | Image rename tool (PowerShell) | 11KB |
| `scripts/restore-from-s3.ps1` | S3 backup restore tool | 9KB |

**Total:** 130KB documentation + code (ready to execute)

---

## Sprint 1: Analytics + Email (Jun 1-14, 8h)

### Setup (15 min each)
```
Plausible account → https://plausible.io
Sentry account    → https://sentry.io
Formspree account → https://formspree.io
```

### Copy Credentials
- Plausible pixel: `<script defer data-domain="..." src="..."></script>`
- Sentry DSN: `https://KEY@ORG.ingest.sentry.io/PROJECT`
- Formspree ID: Copy from create form dialog

### Integrate (2h)
1. Update `js/analytics-sentry.js` with Sentry DSN
2. Update `js/email-form-modal.js` with Formspree ID
3. Add `<head>` scripts to all pages (pixel, Sentry, modal CSS/JS)
4. Update "Orçamento" buttons: `onclick="openEmailModal('Product', 'Category')"`

### Test (3h)
1. Local test: Click Orçamento → form → submit
2. Check email received in comercial@jfernandoamorim.com
3. Verify Plausible dashboard shows events
4. Verify Sentry shows conversions

### Deploy (1h)
```powershell
git add .
git commit -m "Sprint 1: Add analytics + email"
git push origin main
```

---

## Sprint 2: CI/CD + Image + Backup (Jun 15-28, 9h)

### Setup AWS + GitHub (1h)
```powershell
# Create GitHub secrets
Settings → Secrets → Add:
  CLOUDFLARE_API_TOKEN
  CLOUDFLARE_ACCOUNT_ID
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY

# Create S3 bucket
aws s3 mb s3://jfa-backups --region eu-west-1
```

### Deploy Workflow (1h)
1. `.github/workflows/deploy.yml` already created
2. Just push + GitHub Actions auto-executes

### Rename Images (2h)
```powershell
# Dry-run (review proposals)
.\scripts\rename-images.ps1 -Mode dry-run

# Apply (with backups)
.\scripts\rename-images.ps1 -Mode apply

# Cleanup (remove orphaned)
.\scripts\rename-images.ps1 -Mode cleanup
```

### Verify Sitemap (1h)
```powershell
# After deploy, check:
Invoke-WebRequest https://catalogo-3d.pages.dev/sitemap.xml
Invoke-WebRequest https://catalogo-3d.pages.dev/robots.txt
```

### Submit to Google Search Console (1h)
1. https://search.google.com/search-console
2. Add sitemap: `https://catalogo-3d.pages.dev/sitemap.xml`
3. Monitor indexation

### Test CI/CD (2h)
1. Create branch
2. Add inline `<script>` deliberately
3. Push → GitHub Actions should FAIL validation
4. Fix → Push again → should PASS
5. Merge

### Deploy (1h)
```powershell
git add .
git commit -m "Sprint 2: Add CI/CD + image rename + backup"
git push origin main
```

---

## Sprint 3: Cloudflare Workers (Jul 1-15, 3h)

### Create Worker Script (1h)
```javascript
// Cloudflare Worker: edge caching
export default {
  fetch(request) {
    // Cache sitemap 1h
    // Cache products 6h
    // Cache assets 30d
    // Return + cache-control header
  }
}
```

### Deploy + Monitor (2h)
```
Cloudflare Dashboard → Workers → Create
→ Deploy script
→ Test cache hits in Cloudflare Analytics
```

---

## Parallel: Supabase PoC (Jul-Aug, 16h)

**Does NOT block Sprints 1-3**

1. Design schema (products table)
2. Seed from coverage.json
3. API endpoint `/api/products?category=...`
4. Frontend fallback to coverage.json if Supabase offline

---

## Key Scripts Reference

### Image Rename
```powershell
# Review proposals
.\scripts\rename-images.ps1 -Mode dry-run

# Apply renames (creates .bak backups)
.\scripts\rename-images.ps1 -Mode apply

# Find orphaned images
.\scripts\rename-images.ps1 -Mode cleanup
```

### S3 Restore
```powershell
# List available backups
.\scripts\restore-from-s3.ps1 -BackupType daily

# Restore specific backup
.\scripts\restore-from-s3.ps1 -BackupType weekly -Date 20260615
```

### Deploy
```powershell
cd C:\Temp\v01-dist
$env:NODE_TLS_REJECT_UNAUTHORIZED = "0"
npx wrangler pages deploy . --project-name=catalogo-3d
```

---

## Critical Credentials (Store Securely)

- Plausible pixel: Copy to all pages `<head>`
- Sentry DSN: Copy to `js/analytics-sentry.js`
- Formspree ID: Copy to `js/email-form-modal.js`
- AWS keys: GitHub Secrets only (never in code)
- Cloudflare token: GitHub Secrets only

---

## Troubleshooting Quick Links

**Email not arriving:**
- Check Formspree dashboard (form created?)
- Check spam folder
- Verify comercial@jfernandoamorim.com spelling

**GitHub Actions failing:**
- Check Logs (GitHub → Actions → Run)
- Verify secrets configured
- Check JSON syntax: `cat data/coverage.json | ConvertFrom-Json`

**S3 backup not created:**
- Verify AWS credentials: `aws sts get-caller-identity`
- Check bucket: `aws s3 ls s3://jfa-backups/`
- Check IAM user has S3FullAccess

**Image rename errors:**
- Run in PowerShell (not Bash)
- Dry-run first: `.\scripts\rename-images.ps1 -Mode dry-run`
- Check coverage.json has all `asset_path` fields

---

## Success Checklist

### Sprint 1 (Jun 14)
- [ ] Email received in comercial@jfernandoamorim.com
- [ ] Plausible dashboard shows "Orçamento" events
- [ ] Sentry shows conversion tracking
- [ ] Live at https://catalogo-3d.pages.dev/

### Sprint 2 (Jun 28)
- [ ] GitHub Actions workflow passing
- [ ] Images renamed (kebab-case)
- [ ] sitemap.xml accessible
- [ ] robots.txt accessible
- [ ] S3 backups created
- [ ] Restore script tested

### Sprint 3 (Jul 15)
- [ ] Cloudflare Worker deployed
- [ ] Cache hits > 80%
- [ ] Latency < 100ms

---

## Key Decisions Summary

| Decision | Rationale | Backup |
|----------|-----------|--------|
| Plausible | Privacy-first, no cookies, LGPD | N/A (free plan sufficient) |
| Sentry | Error tracking + conversions | Fallback: none (optional) |
| Formspree | Serverless, no backend needed | Upgrade to Brevo if quota exceeded |
| GitHub Actions | Free tier, full validation | Manual validation if needed |
| S3 backup | Cheap, reliable disaster recovery | Local git bundle fallback |
| Image rename | SEO improvement (0 cost) | Keep .bak files 1 week |
| Supabase PoC | Future-ready CMS (non-blocking) | Can defer to September |

---

## Next Person Setup

1. Read: `PHASE3-MASTER-PLAN.md` (architecture overview)
2. Read: `SPRINT1-SETUP.md` (Sprint 1 implementation)
3. Read: `SPRINT2-SETUP.md` (Sprint 2 implementation)
4. Execute: Follow step-by-step in setup docs
5. Reference: This Quick Start for commands

---

## Files to Deliver to Production

✅ All code ready (130KB total):
- Analytics scripts
- Email modal
- GitHub Actions workflow
- Image rename tools
- Restore script
- Documentation (60KB)

**No breaking changes** to existing site.

---

**Master Plan Status: READY FOR EXECUTION**

**Start Date: 01 June 2026**

**Estimated Completion: 15 July 2026**

---

*Created: 26 May 2026 by João Fernando Amorim*
*Project: Catálogo 3D JFA — Phase 3*
