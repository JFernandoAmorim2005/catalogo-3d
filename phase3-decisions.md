# Phase 3 — Decisões Arquitecturais Críticas

**Data:** 26 Maio 2026  
**Status:** Brainstorming Concluído | Pronto para Implementação  
**Timeline:** Sprint 1 (Jun 1-14), Sprint 2 (Jun 15-28), Sprint 3 (Jul 1-15)

---

## 1. Analytics: Plausible + Sentry

### Decisão: Plausible (Privacy-First) + Sentry (Error Tracking)

**Plausible:**
- Sem cookies, LGPD-compliant
- Setup: Pixel de 1 linha em `<head>`
- Eventos: Clique "Orçamento", navegação por categoria
- Dashboard em tempo real (visitas, origem geográfica, dispositivo)

**Sentry:**
- Error tracking para JavaScript
- Eventos críticos: conversões (clique "Orçamento"), modalidades de falha
- Config: `Sentry.init()` em `app.js` com DSN

**Rationale:**
- Stack privacy-first (Cloudflare Pages)
- Sem overhead operacional (SaaS gerenciado)
- LGPD/GDPR compliant (relevante para EU audience)

---

## 2. Email CRM: Formspree (Serverless)

### Decisão: Formspree para submissões de contacto

**Form Flow:**
```
Produto → Clique "Orçamento" → Modal com form
→ Submissão Formspree → Email em comercial@jfernandoamorim.com
→ Confirmação localStorage (opcionalmente redirecionar)
```

**Implementação:**
- HTML form simples `<form action="https://formspree.io/f/{FORM_ID}" method="POST">`
- Campos: email, categoria, mensagem (opcional)
- Inserir em cada página de categoria (modal trigger)

**Alternativas descartadas:**
- Netlify Forms: acoplado a Netlify (JFA em Cloudflare)
- EmailJS: key no frontend (security risk)
- Custom backend: overkill para MVP

**Rationale:**
- Serverless (perfect para Cloudflare Pages)
- Plano gratuito: 50 submissões/mês = 250 contactos/ano
- Sem manutenção de backend

---

## 3. GitHub Actions CI/CD

### Decisão: Validação pré-deploy + staged branch deploys

**Branch Strategy:**
- `main` → Staging automático (Cloudflare Pages branch deploy)
- `releases/*` ou tags `release-*` → Produção (`catalogo-3d.pages.dev`)

**Validação Pré-Deploy (5 min):**
1. **JSON Schema:** `data/coverage.json` válido
2. **HTML Lint:** Sem `<script>` directo (apenas via `data-` attributes)
3. **Image Audit:** Ficheiros orphaned em `img/` (não em coverage.json)
4. **CSS Minification:** Verificar bytes

**Rollback:** Git revert + push (manual, ~2 min)

**Workflow:** `.github/workflows/deploy.yml` (~125 linhas)

**Rationale:**
- Previne erros de data antes de produção
- Validação automática reduz erros manuais
- Staged approach permite QA antes de produção

---

## 4. Image Renaming: Semi-Automático + SEO

### Decisão: Script PowerShell extrai nomes de coverage.json

**Estratégia:**
- Renomear imagens para kebab-case descritivo (ex: `s-l300.jpg` → `motor-basculante-nice-300w.jpg`)
- Extrair nomes de `coverage.json` (`name_display`)
- Identificar órfãs: imagens em `img/` sem entry em coverage.json

**Script:** `scripts/rename-images.ps1`
- Modo dry-run: lista propostas sem executar
- Modo apply: rename + backup `.bak`
- Modo cleanup: remover órfãs

**SEO Benefit:**
- URLs descritivas melhoram CTR no Google Images
- Backlinks contêm contexto (não apenas "123456.jpg")

**Timing:** 1-2h manual (executar antes de Sprint 2 final)

**Rationale:**
- Melhora SEO sem overhead de manutenção
- Semi-automático reduz riscos vs. script cego

---

## 5. Backup S3: Incremental + Snapshot

### Decisão: Daily incremental (git bundle) + Weekly snapshot (tar.gz)

**Frequência:**
- **Daily:** Apenas mudanças (git bundle) → `s3://jfa-backups/daily/` (2h retention)
- **Weekly:** Arquivo completo (tar.gz) → `s3://jfa-backups/weekly/` (90 dias retention)

**Trigger:** GitHub Actions cron (02:00 UTC+1 daily)

**Custo Estimado:** ~$0.50/mês (versioning desativado, lifecycle rules)

**Recuperação:** Script `scripts/restore-from-s3.ps1` (1-click restore)

**Rationale:**
- Disaster recovery para git + imagens
- Custo negligenciável
- Não bloqueia deploy (executa após)

---

## 6. Sitemap + robots.txt: Dinâmico

### Decisão: Gerar automaticamente via GitHub Actions

**sitemap.xml:**
```xml
<urlset>
  <url><loc>https://catalogo-3d.pages.dev/</loc><priority>1.0</priority></url>
  <url><loc>https://catalogo-3d.pages.dev/automatismos.html</loc><priority>0.9</priority></url>
  [12 category pages]
</urlset>
```

**robots.txt:**
```
User-agent: *
Allow: /
Sitemap: https://catalogo-3d.pages.dev/sitemap.xml
```

**Geração:** Script Node.js na GitHub Action

**Rationale:**
- Não exigir manutenção manual
- Automático cada deploy garante atualizado
- Melhora discoverabilidade Google (SEO)

---

## 7. Supabase CMS Lite PoC (Parallel Jul-Aug, 16h)

### Decisão: MVP schema para future content management

**Schema:**
```sql
products (
  id UUID PRIMARY KEY,
  category_key TEXT,
  name_display TEXT,
  description_long TEXT (NULL por enquanto),
  image_cloudinary_url TEXT,
  price_estimate NUMERIC (opcional),
  status ENUM (draft, published),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

**Frontend Fallback:**
- Se Supabase offline → usar `coverage.json`
- API endpoint: `/api/products?category=automatismos`
- Cache: Cloudflare Workers com invalidação em publish

**Migration:** Gerar seed SQL a partir de coverage.json + enrichment manual

**Timeline:** Parallel, não bloqueia Sprints 1-3

**Rationale:**
- Prep para future dynamic content
- Sem breaking changes ao site live
- Exploratory (PoC, não production-ready até Setembro)

---

## Timeline Resumida

| Fase | Sprint | Tarefas | Estimado | Datas |
|------|--------|---------|----------|-------|
| Phase 3 Sprint 1 | 1 | Analytics (Plausible + Sentry), Email form (Formspree) | 8h | Jun 1-14 |
| Phase 3 Sprint 2 | 2 | GitHub Actions CI/CD, Image rename SEO, Backup S3, Sitemap/robots | 9h | Jun 15-28 |
| Phase 3 Sprint 3 | 3 | Cloudflare Workers + KV edge caching | 3h | Jul 1-15 |
| Parallel | CMS PoC | Supabase CMS lite design + PoC | 16h | Jul-Aug |

---

**Status:** Pronto para implementação Sprint 1 (06 Jun)  
**Próxima Acção:** Gerar scripts, HTML snippets, YAML workflows
