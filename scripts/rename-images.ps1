<#
.SYNOPSIS
Renames product images to SEO-friendly names based on product categories.

.PARAMETER DryRun
If specified, shows proposed changes without executing them.
#>

param(
    [switch]$DryRun = $false
)

# Mapping of categories to friendly names
$categoryMap = @{
    "automatismos" = "Automatismo"
    "controlo-acesso" = "Controlo Acesso"
    "cortinados" = "Cortinado"
    "estores" = "Estores"
    "fenolicos" = "Fenolico"
    "logos" = "Logo"
    "mobiliario" = "Mobiliario"
    "pergola" = "Pergola"
    "portas" = "Porta"
    "prot-solar" = "Proteccao Solar"
    "redes-mosquiteiras" = "Rede Mosquiteira"
    "tapetes" = "Tapete"
}

# Counter for renaming
$renameCount = 0

foreach ($category in $categoryMap.Keys) {
    $imgPath = "img/$category"
    
    if (-not (Test-Path $imgPath)) {
        Write-Host "Directory not found: $imgPath" -ForegroundColor Yellow
        continue
    }
    
    # Get all images in the category folder
    $images = Get-ChildItem -Path $imgPath -Include *.jpg, *.jpeg, *.png, *.gif, *.webp -Recurse
    
    foreach ($image in $images) {
        $newName = "$($categoryMap[$category])-$($image.BaseName)"
        $newPath = Join-Path -Path $image.Directory -ChildPath "$newName$($image.Extension)"
        
        if ($DryRun) {
            Write-Host "Would rename: $($image.Name) → $newName$($image.Extension)" -ForegroundColor Cyan
        } else {
            try {
                Rename-Item -Path $image.FullName -NewName "$newName$($image.Extension)" -ErrorAction Stop
                Write-Host "Renamed: $($image.Name) → $newName$($image.Extension)" -ForegroundColor Green
                $renameCount++
            } catch {
                Write-Host "Error renaming $($image.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

if ($DryRun) {
    Write-Host "`nDry run complete. No files were actually renamed." -ForegroundColor Cyan
} else {
    Write-Host "`nCompleted! Renamed $renameCount images." -ForegroundColor Green
    Write-Host "Next: Update HTML coverage.json with new asset_path values." -ForegroundColor Yellow
}
