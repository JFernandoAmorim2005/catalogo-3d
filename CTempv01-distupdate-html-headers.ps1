# Script para actualizar headers HTML com Plausible, Sentry e CSS modal

$htmlFiles = @(
    'C:\Temp\v01-dist\index.html',
    'C:\Temp\v01-dist\automatismos.html',
    'C:\Temp\v01-dist\controlo-acesso.html',
    'C:\Temp\v01-dist\cortinados.html',
    'C:\Temp\v01-dist\estores.html',
    'C:\Temp\v01-dist\fenolicos.html',
    'C:\Temp\v01-dist\logos.html',
    'C:\Temp\v01-dist\mobiliario.html',
    'C:\Temp\v01-dist\pergola.html',
    'C:\Temp\v01-dist\portas.html',
    'C:\Temp\v01-dist\prot-solar.html',
    'C:\Temp\v01-dist\redes-mosquiteiras.html',
    'C:\Temp\v01-dist\tapetes.html'
)

$headInsert = @"
    <link rel="stylesheet" href="css/email-modal.css">

    <!-- Plausible Analytics -->
    <script defer data-domain="catalogo-3d.pages.dev" src="https://plausible.io/js/script.js"></script>

    <!-- Sentry Error Tracking -->
    <script src="https://browser.sentry-cdn.com/7.91.0/bundle.min.js" integrity="sha384-SRf4UErL7UUw5e9B0a0aWVqSKDZFz5+xJ2qpO+jNEgVriqGLeyGYECf3d1Rn6PYh" crossorigin="anonymous"></script>
"@

$scriptInsert = @"

    <script src="js/analytics-sentry.js"></script>
    <script src="js/email-form-modal.js"></script>
"@

foreach ($file in $htmlFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "Arquivo não encontrado: $file" -ForegroundColor Yellow
        continue
    }

    $content = Get-Content $file -Raw

    # Se index.html foi atualizado manualmente, pular
    if ($file -eq 'C:\Temp\v01-dist\index.html' -and $content -contains 'email-modal.css') {
        Write-Host "index.html já foi actualizado. Pulando..." -ForegroundColor Green
        continue
    }

    # Adicionar CSS e scripts no head e antes de </body>
    if (-not ($content -contains 'email-modal.css')) {
        $content = $content -replace '(<link rel="stylesheet" href="css/style.css">)', "`$1`n$headInsert"
    }

    if (-not ($content -contains 'email-form-modal.js')) {
        $content = $content -replace '(<script src="js/app.js"><\/script>)', "$scriptInsert`n    `$1"
    }

    Set-Content $file -Value $content
    Write-Host "Actualizado: $file" -ForegroundColor Green
}

Write-Host "Actualização concluída!" -ForegroundColor Green
