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
$RuleDir = Join-Path $env:USERPROFILE ".gemini\config\rules"
if (!(Test-Path $RuleDir)) {
    New-Item -ItemType Directory -Path $RuleDir -Force | Out-Null
}

$RuleFile = Join-Path $RuleDir "traditional_chinese.md"
$RuleContent = @"
# 繁體中文語言與對話規範 (Traditional Chinese Rules)

## 語言與回應要求
1. **主要語言**：系統與 AI Agent 在所有對話、說明、提示、分析報告、計畫書及文檔輸出中，必須一律使用**正體 / 繁體中文** (Taiwan / Traditional Chinese)。
2. **專業術語**：繁體中文技術用語應符合臺灣與繁體中文習慣（例如：程式碼、專案、伺服器、數據/資料、網路/網絡、執行檔、模組、函數/函式等）。
3. **程式碼與註解**：
   - 程式碼內部關鍵註解與說明文件 (README, Documentation) 預設使用繁體中文說明。
   - 程式碼變數名與語法維持標準英文規範。
4. **Artifacts 與計畫書**：所有產出的 Artifacts (如 implementation_plan.md, walkthrough.md) 必須全篇以繁體中文撰寫。
"@

[System.IO.File]::WriteAllText($RuleFile, $RuleContent, [System.Text.Encoding]::UTF8)
Write-Host "✓ 全域 AI 規則已設定完畢：$RuleFile" -ForegroundColor Green
Write-Host ""

# 2. 配置 Antigravity IDE UI 繁體中文設定 (settings.json / argv.json)
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
$CliTools = @("antigravity", "agy", "code")

foreach ($Cmd in $CliTools) {
    $CommandExists = Get-Command $Cmd -ErrorAction SilentlyContinue
    if ($CommandExists) {
        Write-Host "找到 CLI 工具 ($Cmd)，正在安裝繁體中文語言包..." -ForegroundColor Yellow
        & $Cmd --install-extension MS-CEINTL.vscode-language-pack-zh-hant --force
        $Installed = $true
    }
}

if (-not $Installed) {
    Write-Host "未偵測到全域 CLI 命令 (antigravity/agy)，請確保在 IDE 啟動後於 Extension 搜尋安裝「Chinese (Traditional) Language Pack」。" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " 🎉 Antigravity 繁體中文介面與語系設定完成！ " -ForegroundColor Green
Write-Host " 請重啟 Antigravity IDE / App 以套用完整繁體中文介面。" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
