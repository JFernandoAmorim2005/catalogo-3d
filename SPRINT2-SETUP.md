# Sprint 2: CI/CD, Image Rename, Backup, Sitemap — Setup Guide

**Timeline:** Jun 15-28, 2026 (9h estimadas)  
**Deliverables:**
- GitHub Actions CI/CD pipeline com validação pré-deploy
- Image rename script (SEO optimization)
- S3 incremental backup (daily) + snapshot (weekly)
- Sitemap.xml + robots.txt (automáticos)

---

## Pré-Requisitos

### 1. GitHub Repository Setup (15 min)

Se ainda não tem repositório git:

```powershell
cd C:\Temp\v01-dist

# Initialize git repo
git init
git add .
git commit -m "Initial commit: Catálogo 3D Phase 2"

# Add remote
git remote add origin https://github.com/jfernandoamorim/catalogo-3d.git
git branch -M main
git push -u origin main
```

### 2. GitHub Secrets Configuration (20 min)

No repositório GitHub → Settings → Secrets and variables → Actions

**Adicionar secrets:**

| Secret | Value | Como obter |
|--------|-------|-----------|
| `CLOUDFLARE_API_TOKEN` | Token Cloudflare | https://dash.cloudflare.com/profile/api-tokens (Create Token → Cloudflare Pages, Edit) |
| `CLOUDFLARE_ACCOUNT_ID` | ID da conta | https://dash.cloudflare.com (top-right, copy ID) |
| `AWS_ACCESS_KEY_ID` | AWS access key | https://console.aws.amazon.com/iam (Users → Create Access Key) |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | (Guardar durante creation, não recuperável) |

**AWS Setup (se primeira vez):**
1. Criar IAM user: https://console.aws.amazon.com/iam/
2. Atribuir policy: `AmazonS3FullAccess`
3. Criar access key → copiar ID e secret
4. Criar bucket S3: `jfa-backups` (region: eu-west-1)
5. Configurar lifecycle rules:
   - `daily/*`: Expirar após 2 horas
   - `weekly/*`: Expirar após 90 dias

### 3. AWS S3 Bucket Setup (10 min)

```powershell
# Instalar AWS CLI se não tiver
# https://aws.amazon.com/cli/

# Criar bucket
aws s3 mb s3://jfa-backups --region eu-west-1

# Criar lifecycle configuration (salvar como lifecycle.json)
# Executar depois de criar o arquivo lifecycle.json:
aws s3api put-bucket-lifecycle-configuration `
  --bucket jfa-backups `
  --lifecycle-configuration file://lifecycle.json
```

**Ficheiro `lifecycle.json`:**
```json
{
  "Rules": [
    {
      "Id": "delete-daily-after-2h",
      "Status": "Enabled",
      "Prefix": "daily/",
      "Expiration": {
        "Days": 0,
        "ExpiredObjectDeleteMarker": true
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 0
      }
    },
    {
      "Id": "delete-weekly-after-90d",
      "Status": "Enabled",
      "Prefix": "weekly/",
      "Expiration": {
        "Days": 90
      }
    }
  ]
}
```

---

## Passo 1: Setup GitHub Actions Workflow (1h)

O arquivo `.github/workflows/deploy.yml` já foi criado. Verificar:

1. Ficheiro existe: `C:\Temp\v01-dist\.github\workflows\deploy.yml`
2. GitHub secrets configurados (passo anterior)
3. Testar com push:

```powershell
cd C:\Temp\v01-dist

# Fazer commit
git add .
git commit -m "Sprint 2: Add GitHub Actions CI/CD"
git push origin main

# GitHub Actions deve executar automaticamente
# Verificar em: https://github.com/jfernandoamorim/catalogo-3d/actions
```

**O que o workflow faz:**
- ✓ Validação JSON (coverage.json)
- ✓ HTML lint (sem inline scripts)
- ✓ Image audit (find orphaned)
- ✓ Gera sitemap.xml + robots.txt
- ✓ Deploy para Cloudflare Pages
- ✓ Backup incrementais para S3 (daily + weekly)

---

## Passo 2: Image Rename (SEO Optimization) (2h)

### 2.1 Executar em dry-run mode

```powershell
cd C:\Temp\v01-dist

# Ver propostas de rename sem executar
.\scripts\rename-images.ps1 -Mode dry-run
```

**Output esperado:**
```
Rename:
  FROM: maxresdefault.jpg
  TO:   maxresdefault.jpg
  Display: Maxresdefault

Rename:
  FROM: s-l300.jpg
  TO:   motor-basculante-nice-aluminio.jpg
  Display: Motor Basculante Nice Aluminio

Total proposed renames: 25
```

### 2.2 Revisar e aprovar renames

Analisar propostas:
- Renames descritivos? ✓ (motor-basculante > s-l300)
- Kebab-case válido? ✓ (sem espaços, lowercase)
- Manter extensão .jpg/.png? ✓

### 2.3 Aplicar renames

```powershell
# Executar com apply (cria backups .bak)
.\scripts\rename-images.ps1 -Mode apply
```

**Output esperado:**
```
Backup: maxresdefault.jpg → maxresdefault.jpg.bak
Renamed: maxresdefault.jpg → maxresdefault.jpg

...

Summary:
  Renamed: 25
  Backups: 25
  Errors: 0

SUCCESS: All files renamed. Backups saved with .bak extension
```

### 2.4 Cleanup orphaned images (opcional)

```powershell
# Identificar imagens órfãs
.\scripts\rename-images.ps1 -Mode cleanup
```

Se houver orphaned images, confirmar delete (requer input 'y').

### 2.5 Commit renames

```powershell
git add -A
git commit -m "Sprint 2: Rename images for SEO (kebab-case descriptive names)"
git push origin main
```

---

## Passo 3: Configure AWS Backup (30 min)

### 3.1 Local AWS Credentials

```powershell
# Configure AWS credentials locally
aws configure

# Enter:
# AWS Access Key ID: <YOUR_KEY_ID>
# AWS Secret Access Key: <YOUR_SECRET_KEY>
# Default region: eu-west-1
# Default output format: json
```

### 3.2 Test S3 Connection

```powershell
# Test listing bucket
aws s3 ls s3://jfa-backups/

# Should return empty initially
```

### 3.3 Manual backup test (optional)

```powershell
# Create test backup manually
git bundle create backup-test.bundle --all

# Upload to S3
aws s3 cp backup-test.bundle s3://jfa-backups/daily/

# Verify
aws s3 ls s3://jfa-backups/daily/
```

---

## Passo 4: Verify Sitemap + robots.txt (30 min)

Após primeiro deploy com GitHub Actions:

### 4.1 Verificar sitemap.xml

```powershell
# Descarregar sitemap do site live
Invoke-WebRequest -Uri "https://catalogo-3d.pages.dev/sitemap.xml" -OutFile "sitemap-live.xml"

# Verificar conteúdo
Get-Content "sitemap-live.xml"
```

**Esperado:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://catalogo-3d.pages.dev/</loc>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://catalogo-3d.pages.dev/automatismos.html</loc>
    <priority>0.9</priority>
  </url>
  ...
</urlset>
```

### 4.2 Verificar robots.txt

```powershell
Invoke-WebRequest -Uri "https://catalogo-3d.pages.dev/robots.txt" -OutFile "robots-live.txt"
Get-Content "robots-live.txt"
```

**Esperado:**
```
User-agent: *
Allow: /
Disallow: /node_modules/

Sitemap: https://catalogo-3d.pages.dev/sitemap.xml
```

### 4.3 Submeter sitemap a Google Search Console

1. Aceder a https://search.google.com/search-console
2. Seleccionar propriedade `catalogo-3d.pages.dev`
3. Sitemaps → Adicionar novo sitemap
4. URL: `https://catalogo-3d.pages.dev/sitemap.xml`
5. Submit

---

## Passo 5: Test CI/CD Validation (1h)

### 5.1 Validação deve funcionar

Fazer mudança deliberada e verificar:

```powershell
# Criar branch de test
git checkout -b test/ci-validation

# Fazer mudança que vai falhar validação (propositalmente)
# Ex: adicionar inline <script> em index.html
echo "<script>console.log('test')</script>" >> index.html

git add .
git commit -m "Test: Add inline script (should fail validation)"
git push origin test/ci-validation
```

**Criar PR:**
1. GitHub → New Pull Request → base: main, compare: test/ci-validation
2. GitHub Actions deve executar → deve FALHAR validação
3. Verificar erro: "Found inline <script> in index.html"

### 5.2 Revert e fix

```powershell
# Revert mudança
git checkout index.html

git commit -m "Fix: Remove inline script"
git push origin test/ci-validation

# GitHub Actions deve executar → deve PASSAR
```

### 5.3 Merge + delete branch

```powershell
# Merge via GitHub UI
# Ou via CLI:
git checkout main
git pull origin main
git branch -d test/ci-validation
git push origin --delete test/ci-validation
```

---

## Passo 6: Verify Backups Are Working (30 min)

### 6.1 Verificar backup criado

Após primeiro deploy (GitHub Actions automático):

```powershell
# List daily backups
aws s3 ls s3://jfa-backups/daily/

# List weekly backups
aws s3 ls s3://jfa-backups/weekly/

# Should show recent uploads (timestamps)
```

### 6.2 Test restore script

```powershell
cd C:\Temp\v01-dist

# Testar restore script (dry-run, não executa)
.\scripts\restore-from-s3.ps1 -BackupType daily

# Deve listar backups disponíveis
```

---

## Passo 7: Update Documentation (30 min)

### 7.1 Actualizar README.md

Adicionar seção de Deployment:

```markdown
## 🚀 Deployment (Phase 3 — Sprint 2)

### Automated Deployment
1. Merge to `main` branch
2. GitHub Actions automatically:
   - Validates JSON, HTML, images
   - Generates sitemap.xml + robots.txt
   - Deploys to Cloudflare Pages (https://catalogo-3d.pages.dev/)
   - Creates S3 backups (daily incremental + weekly snapshot)

### Restore from Backup
```powershell
.\scripts/restore-from-s3.ps1 -BackupType daily -Date 20260615-143020
```

### Image Optimization
Rename images for SEO (once):
```powershell
.\scripts/rename-images.ps1 -Mode dry-run  # Review proposals
.\scripts/rename-images.ps1 -Mode apply    # Apply renames
```
```

### 7.2 Guardar documentação de decisões

Ficheiro `phase3-decisions.md` já contém todas as decisões arquitecturais.

---

## Ficheiros Criados/Modificados

### Criados:
- `.github/workflows/deploy.yml` — GitHub Actions CI/CD
- `scripts/rename-images.ps1` — Image rename script (SEO)
- `scripts/restore-from-s3.ps1` — S3 restore script
- `sitemap.xml` — Gerado automaticamente
- `robots.txt` — Gerado automaticamente

### Modificados:
- `README.md` — Adicionar seções Deployment, Backup

### Não modificados:
- HTML pages, CSS, JS — Nenhuma alteração
- `data/coverage.json` — Nenhuma alteração (script lê, não altera)

---

## Troubleshooting

### GitHub Actions workflow falha

1. **Verificar logs:** GitHub → Actions → workflow run → Logs
2. **Secrets não configurados?** Settings → Secrets → verificar CLOUDFLARE_* e AWS_*
3. **Invalid JSON?** Testar localmente: `cat data/coverage.json | ConvertFrom-Json` (PowerShell)

### S3 backup não criado

1. Verificar AWS credentials: `aws sts get-caller-identity`
2. Verificar bucket existe: `aws s3 ls s3://jfa-backups/`
3. Verificar IAM permissions (user deve ter S3FullAccess)

### Image rename script falha

1. Correr em PowerShell (não Bash)
2. Verificar coverage.json tem `asset_path` válidos
3. Verificar arquivo images existem em `img/` directory

### Sitemap/robots.txt não aparecem após deploy

1. Podem levar 5 min para propagar (Cloudflare CDN)
2. Hard refresh: Ctrl+Shift+R
3. Verificar em Deploy Logs → check "Generate sitemap.xml" passou

---

## Próximos Passos (Sprint 3)

- Cloudflare Workers + KV edge caching
- Request caching headers optimization

---

**Status:** Pronto para implementação Sprint 2 (15 Jun)  
**Responsável:** João Fernando Amorim  
**Data Criação:** 26 Maio 2026
