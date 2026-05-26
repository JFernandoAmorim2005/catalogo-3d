# Sprint 1: Analytics + Email CRM — Setup Guide

**Timeline:** Jun 1-14, 2026 (8h estimadas)  
**Deliverables:** 
- Plausible pixel integrado em todas as páginas
- Sentry event tracking para conversões
- Formspree form modal integrado
- Email notifications a comercial@jfernandoamorim.com

---

## Pré-Requisitos

### 1. Criar Conta Plausible (15 min)
1. Aceder a https://plausible.io
2. Sign up → Add domain `catalogo-3d.pages.dev`
3. Copiar pixel script (exemplo):
   ```html
   <script defer data-domain="catalogo-3d.pages.dev" src="https://plausible.io/js/script.js"></script>
   ```

### 2. Criar Conta Sentry (15 min)
1. Aceder a https://sentry.io
2. Criar novo projecto → Platform: JavaScript
3. Copiar DSN (exemplo: `https://YOUR_KEY@YOUR_ORG.ingest.sentry.io/PROJECT_ID`)
4. Guardar DSN para passo 4 abaixo

### 3. Criar Conta Formspree (10 min)
1. Aceder a https://formspree.io
2. Sign up → Create new form
3. Copiar FORM_ID (exemplo: `mjvdydoj`)
4. Guardar para passo 4 abaixo

---

## Passo 1: Actualizar index.html (5 min)

Adicionar no `<head>` (após `<title>`, antes de `</head>`):

```html
<!-- Plausible Analytics -->
<script defer data-domain="catalogo-3d.pages.dev" src="https://plausible.io/js/script.js"></script>

<!-- Sentry + Analytics Events -->
<script src="https://browser.sentry-cdn.com/8.0.0/bundle.min.js"></script>
<script src="js/analytics-sentry.js"></script>

<!-- Email Modal + Formspree -->
<link rel="stylesheet" href="css/email-modal.css">
<script src="js/email-form-modal.js"></script>
```

**Atualizar `js/analytics-sentry.js`:**
Substituir `SENTRY_DSN` pela chave real:
```javascript
const SENTRY_DSN = 'https://YOUR_KEY@YOUR_ORG.ingest.sentry.io/PROJECT_ID';
```

**Atualizar `js/email-form-modal.js`:**
Substituir `FORMSPREE_FORM_ID`:
```javascript
const FORMSPREE_FORM_ID = 'seu_form_id_aqui';
```

---

## Passo 2: Modificar Botão "Orçamento" em Todas as Páginas (2h)

Para cada página de categoria (`automatismos.html`, `controlo-acesso.html`, etc.):

**Antes:**
```html
<button class="btn btn-secondary">Orçamento</button>
```

**Depois:**
```html
<button class="btn btn-secondary" onclick="openEmailModal('<!-- PRODUCT_NAME -->', '<!-- CATEGORY -->')">Orçamento</button>
```

**Exemplo prático (automatismos.html):**
```html
<!-- Product: Maxresdefault -->
<button class="btn btn-secondary" onclick="openEmailModal('Maxresdefault', 'automatismos')">Orçamento</button>

<!-- Product: 32 Home Default -->
<button class="btn btn-secondary" onclick="openEmailModal('32 Home Default', 'automatismos')">Orçamento</button>
```

**Script PowerShell para automatizar (opcional):**
```powershell
# Replace all "Orçamento" buttons with tracked version
Get-ChildItem -Path "C:\Temp\v01-dist" -Filter "*.html" -Exclude "index.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    # Extract product name and category from page context
    $category = $_.BaseName
    # Replace pattern: <button class="btn btn-secondary">Orçamento</button>
    # With: <button class="btn btn-secondary" onclick="openEmailModal(productName, '$category')">Orçamento</button>
    Write-Host "Processing: $($_.Name)"
}
```

---

## Passo 3: Atualizar app.js para Rastreamento de Eventos (1h)

Modificar `js/app.js` para rastrear navegação:

```javascript
// No final de filterProducts():
const resultCount = document.getElementById('resultCount');
if (resultCount) {
  resultCount.textContent = visibleCount;
  // Track search event
  if (window.Analytics && window.Analytics.trackSearch) {
    window.Analytics.trackSearch(query, visibleCount);
  }
}

// Adicionar rastreamento de categoria ao carregar página:
document.addEventListener('DOMContentLoaded', function() {
  // ... existing code ...

  // Track category view
  const pageTitle = document.querySelector('h1')?.textContent || 'unknown';
  if (window.Analytics && window.Analytics.trackCategoryView) {
    window.Analytics.trackCategoryView(pageTitle);
  }
});
```

---

## Passo 4: Testar Integração (1h)

### 4.1. Local Testing (localhost ou staging)

1. Abrir `index.html` no browser (Dev Tools abertos)
2. Verificar console para: `[Analytics] Sentry + Plausible initialized`
3. Verificar console para: `[EmailModal] Initialized and ready`
4. Clicar em botão "Orçamento" numa categoria → deve abrir modal
5. Preencher form + clicar "Enviar"
6. Verificar:
   - Email recebido em comercial@jfernandoamorim.com
   - Mensagem "Orçamento enviado com sucesso"
   - localStorage item `quoteSubmissions` criado

### 4.2. Plausible Dashboard

1. Aceder a https://plausible.io dashboard
2. Deve mostrar eventos em tempo real (pode levar 5 min)
3. Verificar eventos:
   - `Visualizar Categoria`
   - `Pesquisa`
   - `Orçamento Solicitado` (após form submission)

### 4.3. Sentry Dashboard

1. Aceder a https://sentry.io dashboard
2. Verificar eventos `Orçamento Solicitado` com tags `categoria` e `produto`

---

## Passo 5: Deploy para Produção (1h)

### Via Wrangler (Cloudflare Pages)

```powershell
cd C:\Temp\v01-dist

# Set environment variable if needed
$env:NODE_TLS_REJECT_UNAUTHORIZED = "0"

# Deploy
npm run deploy
# or
npx wrangler pages deploy . --project-name=catalogo-3d
```

**Verificação pós-deploy:**
1. Aceder a https://catalogo-3d.pages.dev/
2. Testar form submission novamente
3. Verificar email recebido em comercial@jfernandoamorim.com

---

## Ficheiros Modificados/Criados

### Criados:
- `js/analytics-sentry.js` — Analytics e Sentry setup
- `js/email-form-modal.js` — Modal form com Formspree
- `css/email-modal.css` — Estilos do modal

### Modificados:
- `index.html` — Adicionar scripts + stylesheet (5 linhas no `<head>`)
- `automatismos.html`, `controlo-acesso.html`, ... `tapetes.html` — Atualizar botões "Orçamento" (1 linha por botão)
- `js/app.js` — Adicionar rastreamento de eventos (5 linhas)

### Não modificados:
- `css/style.css` — Compatível com novo CSS modal
- `data/coverage.json` — Nenhuma alteração
- Imagens, outras páginas — Nenhuma alteração

---

## Troubleshooting

### Email não chega em comercial@jfernandoamorim.com

1. Verificar Formspree dashboard → verificar FORM_ID correcto
2. Verificar spam folder
3. Testar submission diretamente em https://formspree.io (interface visual)
4. Verificar Sentry console para erros HTTP (status 422 = validation error)

### Plausible não mostra eventos

1. Verificar que pixel está no `<head>` (usar Dev Tools → Network)
2. Verificar que domain é exacto: `catalogo-3d.pages.dev` (sem https://)
3. Pode levar 5-10 min para aparecer no dashboard
4. Se após 15 min ainda nada: criar novo domain em Plausible

### Sentry mostra muito ruído / muitos erros

1. Aumentar `tracesSampleRate` a 0.01 (1% instead of 10%)
2. Adicionar filters adicionais em `beforeSend()`
3. Desactivar Sentry em desenvolvimento: usar `if (location.hostname !== 'localhost')`

---

## Próximos Passos (Sprint 2)

- GitHub Actions CI/CD automation
- Image rename SEO script
- Backup S3 configuration
- Sitemap.xml + robots.txt generation

---

**Status:** Pronto para implementação  
**Responsável:** João Fernando Amorim  
**Data Criação:** 26 Maio 2026
