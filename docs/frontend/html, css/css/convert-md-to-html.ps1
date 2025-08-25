$mdPath = ".\md"
$htmlPath = ".\html"
$cssFile = ".\style.css"
$templateFile = ".\template.html"

$cssPath = (Resolve-Path $cssFile).Path

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
  
  # Конвертируем md -> html
  pandoc $_.FullName -o $outputFile --standalone --template $templateFile

  # Вручную инлайним css, т.к. pandoc не умеет делать это при использовании кастомного шаблона
  $cssContent = Get-Content $cssPath -Raw
  $htmlContent = Get-Content $outputFile -Raw
  $htmlContent = $htmlContent -replace '<style></style>', "<style>$cssContent</style>"
  Set-Content $outputFile $htmlContent
  
  Write-Host "Converted: $relativePath -> $relativeHtmlPath"
}

Write-Host "Conversion completed!"