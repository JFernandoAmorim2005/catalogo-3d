$files = @(
    "automatismos.html",
    "controlo-acesso.html",
    "cortinados.html",
    "fenolicos.html",
    "logos.html",
    "mobiliario.html",
    "pergola.html",
    "portas.html",
    "prot-solar.html",
    "redes-mosquiteiras.html",
    "tapetes.html"
)

$head = @"
    <link rel="stylesheet" href="css/email-modal.css">

    <!-- Plausible Analytics -->
    <script defer data-domain="catalogo-3d.pages.dev" src="https://plausible.io/js/script.js"></script>

    <!-- Sentry Error Tracking -->
    <script src="https://browser.sentry-cdn.com/7.91.0/bundle.min.js" integrity="sha384-SRf4UErL7UUw5e9B0a0aWVqSKDZFz5+xJ2qpO+jNEgVriqGLeyGYECf3d1Rn6PYh" crossorigin="anonymous"></script>
"@

$scripts = @"

    <script src="js/analytics-sentry.js"></script>
    <script src="js/email-form-modal.js"></script>
"@

foreach ($file in $files) {
    $path = "C:\Temp\v01-dist\$file"
    if (Test-Path $path) {
        $content = Get-Content -Path $path -Raw
        
        if ($content -notcontains 'email-modal.css') {
            $content = $content -replace '(<link rel="stylesheet" href="css/style.css">)', "`$1`n$head"
        }
        
        if ($content -notcontains 'email-form-modal.js') {
            $content = $content -replace '(<script src="js/app.js"><\/script>)', "$scripts`n    `$1"
        }
        
        Set-Content -Path $path -Value $content
        Write-Host "Updated: $file"
    }
}
