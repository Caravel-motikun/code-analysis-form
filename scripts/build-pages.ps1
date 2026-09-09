$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$destination = Join-Path $repoRoot 'site'
$documents = @('README.md','TASK.md','AGENTS.md') + @(Get-ChildItem (Join-Path $repoRoot 'agents'),(Join-Path $repoRoot 'docs'),(Join-Path $repoRoot 'templates') -Recurse -Filter '*.md' | ForEach-Object { [IO.Path]::GetRelativePath($repoRoot,$_.FullName) })
$style = @'
:root{color-scheme:light;--ink:#183332;--accent:#176d60}*{box-sizing:border-box}body{margin:0;color:var(--ink);background:#f5f7f4;font:16px/1.85 system-ui,'Yu Gothic UI',sans-serif}header{background:#183332;color:white;padding:20px max(24px,calc((100% - 1000px)/2))}header a{color:white}main{max-width:1060px;padding:40px 30px;margin:auto}article{background:white;padding:clamp(20px,4vw,56px);border:1px solid #d9e2dc;border-radius:14px}h1{line-height:1.4;font-size:clamp(28px,4vw,40px)}h2{margin-top:2.2em;font-size:24px}h3{font-size:19px}a{color:var(--accent);text-underline-offset:4px}a:focus-visible{outline:3px solid #bf8b2b;outline-offset:4px}pre{overflow:auto;padding:20px;background:#eef3ef;border-radius:8px;line-height:1.65}code{font-family:Consolas,monospace;overflow-wrap:anywhere}pre code{overflow-wrap:normal}table{display:block;overflow-x:auto;border-collapse:collapse;font-size:14px}td,th{padding:12px;min-width:130px;text-align:left;border:1px solid #d9e2dc}th{background:#eef3ef}blockquote{margin-left:0;padding-left:20px;border-left:3px solid #9ebdb0;color:#49615b}footer{margin-top:30px;font-size:13px;color:#526960}@media print{header,footer{display:none}main,article{padding:0;border:0}body{background:white}pre{white-space:pre-wrap}table{display:table;font-size:10px}td,th{min-width:0}}
'@
foreach ($relative in $documents) {
 $inputPath=Join-Path $repoRoot $relative
 $outputRelative=[IO.Path]::ChangeExtension($relative,'html')
 $outputPath=Join-Path $destination $outputRelative
 New-Item -ItemType Directory -Path (Split-Path $outputPath) -Force | Out-Null
 $md=Get-Content -LiteralPath $inputPath -Raw
 $html=(ConvertFrom-Markdown -InputObject $md).Html
 $html=[regex]::Replace($html,'href="(?!https?://)([^"#]+)\.md(?=[#"])', 'href="$1.html')
 $title=[Net.WebUtility]::HtmlEncode(($md -split "`n")[0].TrimStart('#',' '))
 $homeLink=[IO.Path]::GetRelativePath((Split-Path $outputPath),(Join-Path $repoRoot 'index.html')).Replace('\','/')
 $source=[IO.Path]::GetRelativePath((Split-Path $outputPath),$inputPath).Replace('\','/')
 $page="<!doctype html><html lang=`"ja`"><head><meta charset=`"utf-8`"><meta name=`"viewport`" content=`"width=device-width,initial-scale=1`"><title>$title | Multi-View Analysis</title><style>$style</style></head><body><header><a href=`"$homeLink`">← Multi-View Analysis</a></header><main><article>$html</article><footer><a href=`"$source`">Markdown原文</a> · 設計コンテキスト / Code Analysis Form</footer></main></body></html>"
 [IO.File]::WriteAllText($outputPath,$page,[Text.UTF8Encoding]::new($false))
}
New-Item -ItemType Directory -Path (Join-Path $destination 'references') -Force | Out-Null
Copy-Item (Join-Path $repoRoot 'references/*.html') (Join-Path $destination 'references')
Write-Output "Generated $($documents.Count) document pages and reference HTML."
