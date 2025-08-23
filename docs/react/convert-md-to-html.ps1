$mdPath = ".\md"
$htmlPath = ".\html"
$cssFile = ".\style.css"

# Проверяем существование CSS файла
if (Test-Path $cssFile) {
    $cssPath = (Resolve-Path $cssFile).Path
} else {
    Write-Host "Warning: CSS file not found - $cssFile"
    $cssPath = $null
}

Get-ChildItem -Path $mdPath -Recurse -Filter "*.md" | ForEach-Object {
    # Получаем относительный путь от папки md
    $relativePath = $_.FullName.Substring((Resolve-Path $mdPath).Path.Length + 1)
    
    # Заменяем расширение .md на .html
    $relativeHtmlPath = $relativePath -replace '\.md$', '.html'
    
    # Формируем полный путь к выходному файлу
    $outputFile = Join-Path $htmlPath $relativeHtmlPath
    
    # Создаем директорию для выходного файла
    $outputDir = Split-Path $outputFile -Parent
    if (!(Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # Конвертируем файл с добавлением CSS
    if ($cssPath) {
        pandoc $_.FullName -o $outputFile --css style.css --standalone --self-contained
    } else {
        pandoc $_.FullName -o $outputFile
    }
    
    Write-Host "Converted: $relativePath -> $relativeHtmlPath"
}

Write-Host "Conversion completed!"