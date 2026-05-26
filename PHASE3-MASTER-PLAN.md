# Phase 3 Complete — Master Implementation Plan

**Data:** 26 Maio 2026  
**Status:** Brainstorming + Implementação Pronto  
**Directiva:** BRIO Autonomia Total (Absorber → Delinear → Planear → Brainstorm → Reflectir → Implementar)

---

## Executive Summary

**Catálogo 3D JFA Phase 3** expande MVP (live em produção) com:
- **Analytics & CRM:** Plausible (privacy-first) + Sentry (error tracking) + Formspree (email leads)
- **CI/CD Automation:** GitHub Actions com validação pré-deploy + staged branch deploys
- **SEO Optimization:** Image rename script (kebab-case), sitemap.xml, robots.txt automáticos
- **Disaster Recovery:** S3 incremental backups (daily) + weekly snapshots
- **Future-Ready:** Supabase CMS PoC (Julho-Agosto, 16h parallel, não bloqueia)

**Total Phase 3 Timeline:**
- **Sprint 1 (Jun 1-14, 8h):** Analytics + Email CRM
- **Sprint 2 (Jun 15-28, 9h):** CI/CD + Image rename + Backup + Sitemap
- **Sprint 3 (Jul 1-15, 3h):** Cloudflare Workers edge caching
- **Parallel (Jul-Aug, 16h):** Supabase CMS Lite PoC

---

## Decisões Arquitecturais Críticas

### 1. Analytics: Plausible + Sentry

**Por quê Plausible?**
- Privacy-first (sem cookies, LGPD-compliant)
- Ideal para EU audience (JFA em PT-PT)
- Setup trivial (pixel 1-liner)
- Dashboard em tempo real

**Por quê Sentry?**
- Error tracking + crash reporting
- Events críticos: conversões (clique "Orçamento")
- Integração com analytics eventos

**Eventos rastreados:**
1. Visualizar categoria
2. Pesquisa por termo
3. Clique "Orçamento" (conversão crítica)
4. Form submission (email lead)

---

### 2. Email CRM: Formspree (Serverless)

**Rationale:**
- Cloudflare Pages não tem backend nativo
- Formspree: sem infrastructure, plano gratuito 50 submissões/mês
- Fallback: se quota ultrapassar, upgrade para Brevo SMTP

**Flow:**
```
Clique "Orçamento" → Modal HTML5
→ Submissão Formspree POST (sem reload)
→ Email comercial@jfernandoamorim.com
→ localStorage: guardar submission para follow-up
```

---

### 3. GitHub Actions CI/CD

**Branch Strategy:**
- `main` → staging automático (Cloudflare Pages branch deploy)
- `releases/*` → produção (manual merge, automático deploy)

**Validação Pré-Deploy (5 min):**
1. JSON schema válido (coverage.json)
2. HTML sem inline `<script>` (segurança)
3. Image audit: find orphaned files
4. CSS minification check

**Rollback:** Git revert + push (manual, 2 min)

---

### 4. Image Rename: Semi-Automático

**Estratégia:**
- Script PowerShell extrai `name_display` de coverage.json
- Converte para kebab-case SEO-friendly
- Dry-run mode: review antes de aplicar
- Apply mode: rename + backup .bak

**SEO Benefit:**
- `s-l300.jpg` → `motor-basculante-nice-aluminio.jpg`
- Google Images: URLs descritivas = melhor CTR
- Backlinks contêm contexto

---

### 5. Backup S3: Incremental + Snapshot

**Frequência:**
- **Daily:** Git bundle (apenas mudanças) → expira 2h
- **Weekly:** Tar.gz completo → retenção 90 dias

**Custo:** ~$0.50/mês (negligenciável)

**Recuperação:** Script `restore-from-s3.ps1` (1-click)

---

### 6. Sitemap + Robots: Dinâmico

**Gerado automaticamente** via GitHub Actions (cada deploy):
- `sitemap.xml`: todas as 13 páginas com priority scores
- `robots.txt`: Allow all, sitemap reference

**SEO:** Melhora discoverabilidade Google

---

### 7. Supabase CMS Lite PoC (Parallel, Julho-Agosto)

**Não bloqueia Sprints 1-3.** Exploratory (future dynamic content):
- Schema: products table (id, category, name, description, image_url, status)
- Fallback ao coverage.json se offline
- API endpoint: `/api/products?category=automatismos`
- Cache: Cloudflare Workers com invalidação em publish

**Timeline:** 16h parallel (não interfere com deployment sprints)

---

## Implementation Roadmap

### Sprint 1: Analytics + Email CRM (Jun 1-14, 8h)

**Tarefas:**
1. Setup Plausible account + pixel
2. Setup Sentry account + DSN
3. Setup Formspree account + FORM_ID
4. Criar `js/analytics-sentry.js` + `js/email-form-modal.js`
5. Criar `css/email-modal.css`
6. Integrar em todas as páginas
7. Test + deploy
8. Validar: email recebido em comercial@jfernandoamorim.com

**Deliverables:**
- Analytics pixel em todas as páginas
- Email modal com form
- Event tracking para conversões
- Live em produção

**Timeline realista:** 8h (inclui setup accounts, testing, troubleshooting)

---

### Sprint 2: CI/CD + Image Rename + Backup + Sitemap (Jun 15-28, 9h)

**Tarefas:**
1. Configurar GitHub Actions workflow (`.github/workflows/deploy.yml`)
2. Configurar GitHub secrets (CLOUDFLARE_*, AWS_*)
3. Criar S3 bucket + lifecycle rules
4. Implementar image rename script PowerShell
5. Test rename em dry-run mode → review → apply
6. Verificar sitemap.xml + robots.txt gerados
7. Test CI/CD validation (PR → fail → fix → merge)
8. Test S3 backup creation
9. Deploy final + verify

**Deliverables:**
- GitHub Actions workflow automático
- Imagens renomeadas com nomes descritivos SEO
- S3 backups daily + weekly
- Sitemap.xml + robots.txt automáticos
- Live em produção

**Timeline realista:** 9h (inclui setup AWS, testing, troubleshooting)

---

### Sprint 3: Cloudflare Workers Edge Caching (Jul 1-15, 3h)

**Tarefas:**
1. Criar Cloudflare Workers script para caching dinâmico
2. Configurar cache headers (sitemap: 1h, products: 6h, assets: 30d)
3. KV bindings para version control
4. Deploy + validate cache hits
5. Monitor Cloudflare Analytics

**Deliverables:**
- Edge caching automático (< 100ms latency)
- Invalidação de cache intelligente
- Performance metrics dashboard

**Timeline realista:** 3h

---

### Parallel: Supabase CMS Lite PoC (Jul-Aug, 16h)

**Não bloqueia nenhum sprint.** Exploratory work:
- Design schema (products, categories)
- Seed data a partir de coverage.json
- API endpoint basic CRUD
- Frontend fallback ao coverage.json se Supabase offline

**Timing:** Agosto (após Sprints 1-3 production)

---

## Ficheiros & Artefactos Gerados

### Criados Hoje (26 Mai):

```
phase3-decisions.md
├── Decisões arquitecturais (7 componentes)
├── Timeline + rationales
└── Próximos passos

js/analytics-sentry.js
├── Plausible pixel + Sentry init
├── Event tracking functions
└── Window.Analytics API

js/email-form-modal.js
├── Modal HTML5 (sem render framework)
├── Formspree integration
├── localStorage para submissions
└── Error handling

css/email-modal.css
├── Modal styles (responsive)
├── Form input styles
└── Animation (fadeIn, slideIn)

SPRINT1-SETUP.md
├── Pré-requisitos (Plausible, Sentry, Formspree accounts)
├── Step-by-step integration
├── Testing checklist
├── Troubleshooting

.github/workflows/deploy.yml
├── Validação JSON/HTML/images
├── Geração sitemap.xml + robots.txt
├── Deploy automático Cloudflare
└── S3 backup creation

scripts/rename-images.ps1
├── Dry-run mode (review proposals)
├── Apply mode (rename + backup)
├── Cleanup mode (remove orphaned)
└── Integration com coverage.json

scripts/restore-from-s3.ps1
├── List available backups
├── Download de S3
├── Restore via git bundle ou tar.gz
└── Error handling

SPRINT2-SETUP.md
├── AWS/GitHub/S3 configuration
├── Image rename procedure
├── CI/CD validation testing
├── Sitemap verification
└── Troubleshooting

PHASE3-MASTER-PLAN.md (este ficheiro)
├── Executive summary
├── Decisões arquitecturais
├── Implementation roadmap
├── Checklist & responsabilidades
```

---

## Pre-Flight Checklist

### Antes de Sprint 1 (Jun 1):

- [ ] Criar conta Plausible (FREE plan) → copiar pixel + domain
- [ ] Criar conta Sentry (FREE plan) → copiar DSN
- [ ] Criar conta Formspree (FREE plan) → copiar FORM_ID
- [ ] Ler `SPRINT1-SETUP.md` completamente
- [ ] Copiar ficheiros Sprint 1 para repositório
- [ ] Testar local (index.html + 1 categoria)

### Antes de Sprint 2 (Jun 15):

- [ ] Completar Sprint 1 testing + deploy
- [ ] GitHub repository criado + initial commit
- [ ] Ler `SPRINT2-SETUP.md` completamente
- [ ] Criar GitHub secrets (CLOUDFLARE_*, AWS_*)
- [ ] Criar AWS account + S3 bucket
- [ ] Copiar ficheiros Sprint 2 (workflows, scripts)

### Antes de Sprint 3 (Jul 1):

- [ ] Completar Sprint 2 + validate CI/CD
- [ ] Ler Cloudflare Workers documentation
- [ ] Preparar Cloudflare Worker script

---

## Success Metrics

### Sprint 1:
- ✓ Email recebido em comercial@jfernandoamorim.com após form submission
- ✓ Plausible dashboard mostra eventos em tempo real
- ✓ Sentry mostra conversões rastreadas
- ✓ localStorage contém submissions (JSON array)

### Sprint 2:
- ✓ GitHub Actions workflow executa + deploy automático
- ✓ Imagens renomeadas com nomes descritivos (kebab-case)
- ✓ sitemap.xml + robots.txt acessíveis no site live
- ✓ S3 backups criados (daily + weekly)
- ✓ Restore script funciona

### Sprint 3:
- ✓ Cloudflare Worker caching ativo
- ✓ Cache hits > 80% (Cloudflare Analytics)
- ✓ Latency < 100ms (edge)

---

## Decisões Postergadas (Futuro)

### Não incluído em Phase 3:

1. **A/B Testing (Optimizely)** — Post-August, analytics baseline primeiro
2. **Advanced Search (Algolia)** — Coverage.json search suficiente por enquanto
3. **CDN Image Optimization (Cloudinary)** — Images já lazyload, PQDN no roadmap
4. **Database Migration (full Supabase)** — PoC em Julho, migration fase posterior
5. **Mobile App** — Web-first, responsive funciona em todos dispositivos
6. **Multi-language** — PT-PT primeiro, i18n post-August

---

## Risk Mitigation

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Formspree quota (50/mês) | Lead loss | Upgrade para Brevo SMTP se ultrapassar |
| GitHub Actions delay | Slower deploy | Cron backup separado (S3 directly) |
| S3 restoration failure | Data loss | Semanal test restore (automation) |
| Image rename errors | Broken links | Dry-run mode mandatory + backup .bak |
| Supabase schema design | Future complexity | PoC phase permite iteração sem bloquear |

---

## Responsabilidades & Ownership

**João Fernando Amorim (JFA):**
- [ ] Sprint 1 implementação completa (Analytics + Email)
- [ ] Sprint 2 implementação completa (CI/CD + Image + Backup)
- [ ] Sprint 3 implementação (Cloudflare Workers)
- [ ] Testing + validation antes de cada deploy
- [ ] Email lead response (comercial@jfernandoamorim.com)

**Automação (GitHub Actions + Cloudflare):**
- [x] Deploy automático post-commit
- [x] Validação pré-deploy
- [x] S3 backup automático
- [x] Sitemap generation

---

## Budget & Costs Estimate

| Serviço | Plan | Custo/mês | Notas |
|---------|------|-----------|-------|
| Plausible | FREE | €0 | 10k pageviews/mês grátis |
| Sentry | FREE | €0 | 5k events/mês grátis |
| Formspree | FREE | €0 | 50 submissões/mês grátis |
| AWS S3 | Standard | ~$0.50 | Backup storage (lifecycle rules 90d) |
| Cloudflare Pages | FREE | €0 | Deploy + staging |
| Cloudflare Workers | FREE | €0 | 100k requests/dia grátis |
| GitHub | FREE | €0 | Public repo |
| **Total** | | **~€0.50** | (AWS só se active) |

**ROI:** Próximo a zero custo, máximo valor (production-grade infrastructure)

---

## Knowledge Transfer

### Para onboard outro developer:

1. Ler `phase3-decisions.md` (arquitectura)
2. Ler `SPRINT1-SETUP.md` + `SPRINT2-SETUP.md` (implementação)
3. Clonar repo + `npm install` + `npm run deploy`
4. Verificar GitHub Actions → S3 backups → Plausible dashboard
5. Testar restore script: `.\scripts\restore-from-s3.ps1`

---

## References & Tools

- Plausible Docs: https://plausible.io/docs
- Sentry Docs: https://docs.sentry.io/platforms/javascript/
- Formspree Docs: https://formspree.io/docs
- GitHub Actions: https://docs.github.com/actions
- Cloudflare Workers: https://developers.cloudflare.com/workers/
- AWS S3: https://docs.aws.amazon.com/s3/
- Supabase Docs: https://supabase.io/docs

---

## Status & Next Steps

**✅ Phase 3 Brainstorming:** Completo (26 Mai 2026)
- Decisões arquitecturais documentadas
- Todos os artefactos criados
- Setup guides prontos-a-executar
- Risk mitigation identificado

**→ Sprint 1 (Jun 1-14):**
1. Criar accounts (Plausible, Sentry, Formspree)
2. Integrar scripts + CSS
3. Test completo
4. Deploy + validate

**→ Sprint 2 (Jun 15-28):**
1. GitHub Actions + secrets
2. Image rename + backup
3. CI/CD validation testing
4. Deploy + verify sitemap

**→ Sprint 3 (Jul 1-15):**
1. Cloudflare Workers script
2. Deploy + monitor cache hits

**→ Parallel (Jul-Aug):**
Supabase CMS Lite PoC (non-blocking)

---

## Conclusão

**Phase 3 Phase 3 está estruturado, desriscado e pronto para execução automática seguindo directiva BRIO.**

Arquitetura escolhida é:
- **Privacy-first** (Plausible)
- **Serverless** (Formspree, Cloudflare Workers)
- **Production-grade** (GitHub Actions, S3 backup, Sentry)
- **Zero-cost** (plannings gratuitos)
- **SEO-optimized** (sitemap, robots, image naming)

Roadmap é realista (20h total para Sprints 1-3), com paralelização adequada para Supabase PoC.

**Directiva BRIO aplicada:** Autonomia total para implementação, zero dependências externas, decisões arquiteturais justificadas, risco mitigado.

---

**Pronto para Implementação Sprint 1: 01 Junho 2026**

**Autor:** João Fernando Amorim  
**Email:** comercial@jfernandoamorim.com  
**Data:** 26 Maio 2026  
**Projecto:** Catálogo 3D JFA — Phase 3 Master Plan
