# Operações & Manutenção — Catálogo 3D JFA

**Para:** Equipa de operações | **Atualizado:** 2026-05-26

---

## 📋 Adicionar Novo Produto

### Pré-requisitos
- Foto do produto (JPG, min 400×300px)
- Nome descritivo
- Categoria existente (ou nova)

### Passos

#### 1. Preparar imagem
```bash
# Guardar em /img/[categoria]/
# Exemplo: C:\temp\v01-dist\img\estores\estore-horizontal-aluminio.jpg

# Naming convention: [tipo]-[modelo].jpg (sem espaços, sem acentos)
# ✓ correcto: estore-madeira-escura.jpg
# ✗ errado: Estore Madeira-Escura.JPG
```

#### 2. Actualizar inventory (coverage.json)
```json
{
  "products": {
    "estores-001": {
      "asset_path": "img/estores/estore-horizontal-aluminio.jpg",
      "name_display": "Estore Horizontal Alumínio",
      "tier": "2d",
      "category": "estores"
    }
  }
}
```

#### 3. Categoria HTML atualiza automaticamente
- Não precisa editar `estores.html` manualmente
- Layout grid carrega de `coverage.json`

#### 4. Deploy
```powershell
cd C:\temp\v01-dist
npm run deploy
```

---

## 🆕 Adicionar Nova Categoria

### 1. Template HTML
Copiar `portas.html` → `nova-categoria.html`

```html
<!-- Nova Categoria: TAPETES -->
<h2>Tapetes</h2>
<div class="product-grid" id="tapetes-grid">
  <!-- Carregará de coverage.json -->
</div>
```

### 2. Actualizar index.html
```html
<!-- Adicionar em secção Categorias -->
<nav class="categories-nav">
  ...
  <a href="nova-categoria.html">Nova Categoria</a>
</nav>
```

### 3. Atualizar coverage.json
```json
{
  "categories_index": {
    "nova-categoria": [
      "produto-001",
      "produto-002"
    ]
  }
}
```

### 4. Deploy
```powershell
npm run deploy
```

---

## 🔄 Rollback Rápido

Caso de uso: Deployment errado, precisa reverter.

### Via Cloudflare Dashboard
1. Abrir https://dash.cloudflare.com/
2. Navegar a **Pages** → **catalogo-3d**
3. Aba **Deployments**
4. Seleccionar deployment anterior (timestamp)
5. Click **Rollback to this version**

**Tempo:** < 2 minutos

### Via CLI (alternativa)
```powershell
cd C:\temp\v01-dist

# Listar deployments
npx wrangler pages deployment list --project-name=catalogo-3d

# Rollback (especificar ID)
npx wrangler pages deployment rollback \
  --project-name=catalogo-3d \
  --deployment-id=<id>
```

---

## 📊 Monitorar Performance & Erros

### HTTP Status Monitoring
```powershell
# Validação remota (Python)
python C:\temp\validate-remote.py

# Resultado esperado: todos HTTP 200
```

### Erros em Produção
Após Phase 3, verificar:
- Sentry dashboard: https://sentry.io/ (erros JS)
- Cloudflare Analytics: Views, bounce rate, device mix
- Email orçamentos: Inbox para leads

**Frequência:** Daily check (5 min)

---

## 🔐 Segurança & Backups

### Backup Manual
```powershell
# Backup completo a drive externo
Copy-Item -Recurse C:\temp\v01-dist D:\backup\catalogo-3d-$(date +%Y-%m-%d)

# Ou via GitHub (recomendado)
git add . && git commit -m "Daily backup $(date)"
git push origin main
```

### Recovery
```powershell
# Se ficheiro corrompido, revert em GitHub
git revert <commit-hash>
git push origin main

# Deploy automático (quando Phase 3 CI/CD ativo)
# Cloudflare Pages rebuilds automaticamente
```

---

## 📈 Checklist Deploy

Antes de fazer `npm run deploy`:

- [ ] Todos os ficheiros novos adicionados a `coverage.json`
- [ ] Images em `/img/[categoria]/` com naming correcto
- [ ] HTML validação: `npm run lint` (quando Phase 3)
- [ ] JSON validação: `npx ajv validate -s coverage.schema.json -d data/coverage.json`
- [ ] Backup local criado: `git commit -m "Pre-deploy backup"`

---

## 🚨 Troubleshooting

### Imagem não aparece na categoria
1. Verificar path em `coverage.json` — deve ser relativo a raiz (`img/categoria/file.jpg`)
2. Verificar file exists: `Test-Path C:\temp\v01-dist\img\categoria\file.jpg`
3. Clear cache: `Ctrl+Shift+Delete` no browser

### Deploy falha com erro de network
```powershell
# Desabilitar SSL verification (Windows environment workaround)
$env:NODE_TLS_REJECT_UNAUTHORIZED = "0"
npm run deploy
```

### Categoria HTML branca/vazia
1. Browser console: `F12` → **Console** → há erros?
2. Verificar `coverage.json` parsing: Abrir em VS Code, valide JSON
3. Verificar IDs em `categories_index` existem em `products`

---

## 📞 Contacto & Escalação

**Admin:** comercial@jfernandoamorim.com  
**Production URL:** https://catalogo-3d.pages.dev/  
**Repository:** GitHub (Phase 3)

---

**Última atualização:** 2026-05-26  
**Próxima revisão:** 2026-06-15 (após Phase 3 analytics)
