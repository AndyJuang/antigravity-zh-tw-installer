# ==============================================================================
# Google Antigravity 繁體中文介面與語系設定安裝腳本 (Windows PowerShell)
# ==============================================================================

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   Google Antigravity 繁體中文語系安裝程式 (Windows)   " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# 1. 配置 Antigravity 全域 AI Agent 繁體中文 Rule 規範
Write-Host "[1/3] 正在安裝 Antigravity 全域繁體中文 AI 規則..." -ForegroundColor Blue
$GeminiDir = Join-Path $env:USERPROFILE ".gemini\config"
$RuleDir = Join-Path $GeminiDir "rules"
if (!(Test-Path $RuleDir)) {
    New-Item -ItemType Directory -Path $RuleDir -Force | Out-Null
}

$RuleContent = @"
# 繁體中文對話與回應規範 (Traditional Chinese Rule)

- **主要語言**：所有 AI Agent 的對話、說明、提示、分析報告、計畫書及文檔輸出，必須一律使用 **正體 / 繁體中文** (Taiwan / Traditional Chinese)。
- **專業術語**：請使用臺灣與繁體中文標準用語（例如：程式碼、專案、伺服器、數據/資料、網路、執行檔、函式/函數、模組等）。
- **計畫書與報告**：所有產出的 Artifacts (如 implementation_plan.md, walkthrough.md) 必須全篇以繁體中文撰寫。
"@

$GeminiFile = Join-Path $GeminiDir "GEMINI.md"
$AgentsFile = Join-Path $GeminiDir "AGENTS.md"
$RuleFile = Join-Path $RuleDir "traditional_chinese.md"

[System.IO.File]::WriteAllText($GeminiFile, $RuleContent, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($AgentsFile, $RuleContent, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($RuleFile, $RuleContent, [System.Text.Encoding]::UTF8)
Write-Host "✓ 全域 AI 規則已設定完畢：$GeminiFile" -ForegroundColor Green
Write-Host ""

# 2. 配置 Antigravity IDE UI 繁體中文設定 (locale.json / settings.json / argv.json)
Write-Host "[2/3] 正在配置 Antigravity IDE 繁體中文介面設定..." -ForegroundColor Blue

$ConfigPaths = @(
    (Join-Path $env:APPDATA "Antigravity\User"),
    (Join-Path $env:APPDATA "Code\User"),
    (Join-Path $env:USERPROFILE ".config\antigravity\User")
)

foreach ($ConfDir in $ConfigPaths) {
    $ParentDir = Split-Path $ConfDir -Parent
    if (Test-Path $ParentDir) {
        if (!(Test-Path $ConfDir)) {
            New-Item -ItemType Directory -Path $ConfDir -Force | Out-Null
        }

        # 設定 locale.json
        $LocaleFile = Join-Path $ConfDir "locale.json"
        Set-Content -Path $LocaleFile -Value '{"locale": "zh-tw"}' -Encoding UTF8

        # 設定 argv.json
        $ArgvFile = Join-Path $ConfDir "argv.json"
        if (!(Test-Path $ArgvFile)) {
            Set-Content -Path $ArgvFile -Value '{"locale": "zh-tw"}' -Encoding UTF8
        } else {
            $ArgvContent = Get-Content $ArgvFile -Raw
            if ($ArgvContent -match '"locale"') {
                $ArgvContent = $ArgvContent -replace '"locale": *"[^"]*"', '"locale": "zh-tw"'
            } else {
                $ArgvContent = $ArgvContent -replace '\{', "{\n  `"locale`": `"zh-tw`","
            }
            [System.IO.File]::WriteAllText($ArgvFile, $ArgvContent, [System.Text.Encoding]::UTF8)
        }

        # 設定 settings.json
        $SettingsFile = Join-Path $ConfDir "settings.json"
        if (!(Test-Path $SettingsFile)) {
            $SettingsContent = @"
{
  "antigravity.language": "zh-TW",
  "workbench.preferredLanguage": "zh-tw"
}
"@
            [System.IO.File]::WriteAllText($SettingsFile, $SettingsContent, [System.Text.Encoding]::UTF8)
        }
        Write-Host "✓ 已寫入 IDE 語系配置：$ConfDir" -ForegroundColor Green
    }
}

Write-Host ""

# 3. 安裝繁體中文語言包擴充套件 (Language Pack)
Write-Host "[3/3] 正在嘗試安裝 IDE 繁體中文語言包擴充套件..." -ForegroundColor Blue

$Installed = $false
$CliTools = @("antigravity", "code")

foreach ($Cmd in $CliTools) {
    $CommandExists = Get-Command $Cmd -ErrorAction SilentlyContinue
    if ($CommandExists) {
        Write-Host "找到 CLI 工具 ($Cmd)，正在安裝繁體中文語言包..." -ForegroundColor Yellow
        & $Cmd --install-extension MS-CEINTL.vscode-language-pack-zh-hant --force
        $Installed = $true
    }
}

if (-not $Installed) {
    Write-Host "提示：若選單未自動變更中文，請在 IDE 中按下 Ctrl+Shift+P 搜尋「Configure Display Language」選取「zh-tw (繁體中文)」。" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " 🎉 Antigravity 繁體中文介面與語系設定完成！ " -ForegroundColor Green
Write-Host " 請完全關閉並重啟 Antigravity IDE / App 以套用變更。" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
