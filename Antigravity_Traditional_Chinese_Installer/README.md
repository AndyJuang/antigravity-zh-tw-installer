# Google Antigravity 繁體中文介面與對話安裝包

本安裝包包含適用於 **macOS** 與 **Windows** 的自動化設定與安裝腳本，能一鍵完成以下三項配置：

1. **AI Agent 對話語系與規範 (Global Rules)**：配置 `~/.gemini/config/rules/traditional_chinese.md`，使 Antigravity AI Agent 一律採用繁體中文（台灣繁體術語）對話、回覆、說明與撰寫計畫文檔。
2. **Antigravity IDE 語系介面設定**：自動寫入 `argv.json` 與 `settings.json` 的 `"locale": "zh-tw"` 設定。
3. **IDE 繁體中文語言包**：自動透過 CLI 安裝 Microsoft 繁體中文語言包套件 (`MS-CEINTL.vscode-language-pack-zh-hant`)。

---

## 🚀 使用說明

### 🍎 macOS 使用者

#### 方法 1：點擊圖示直接安裝 (推薦)
1. 開啟 `macOS/` 資料夾。
2. 雙擊點擊 `install_zh_TW_mac.command` 檔案。
3. 系統會自動開啟 Terminal 終端機進行安裝，完成後顯示成功訊息並關閉即可。

#### 方法 2：終端機命令安裝
開啟 Terminal 執行以下指令：
```bash
./macOS/install_zh_TW_mac.sh
```

---

### 🪟 Windows 使用者

#### 方法 1：雙擊批次檔安裝 (推薦)
1. 開啟 `Windows\` 資料夾。
2. 連點兩下執行 `install_zh_TW_win.bat`。
3. 視窗會自動喚起 PowerShell 完成語系安裝與全域 Rule 設定。

#### 方法 2：PowerShell 命令安裝
開啟 PowerShell 並執行：
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Windows\install_zh_TW_win.ps1
```

---

## 📌 完成後操作
安裝完成後，請**重啟 Antigravity IDE / App**。
IDE 介面將切換為繁體中文，且 AI 對話與產出報告將自動全面套用繁體中文。
