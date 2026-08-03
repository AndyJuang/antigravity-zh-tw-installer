#!/bin/bash
# ==============================================================================
# Google Antigravity 繁體中文介面與語系設定安裝包 (macOS 版)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   Google Antigravity 繁體中文語系安裝程式 (macOS)   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# 1. 配置 Antigravity 全域 AI Agent 繁體中文 Rule 規範
echo -e "${BLUE}[1/3] 正在安裝 Antigravity 全域繁體中文 AI 規則...${NC}"
RULE_DIR="$HOME/.gemini/config/rules"
mkdir -p "$RULE_DIR" 2>/dev/null

RULE_FILE="$RULE_DIR/traditional_chinese.md"
cat << 'EOF' > "$RULE_FILE" 2>/dev/null
# 繁體中文語言與對話規範 (Traditional Chinese Rules)

## 語言與回應要求
1. **主要語言**：系統與 AI Agent 在所有對話、說明、提示、分析報告、計畫書及文檔輸出中，必須一律使用**正體 / 繁體中文** (Taiwan / Traditional Chinese)。
2. **專業術語**：繁體中文技術用語應符合臺灣與繁體中文習慣（例如：程式碼、專案、伺服器、數據/資料、網路/網絡、執行檔、模組、函數/函式等）。
3. **程式碼與註解**：
   - 程式碼內部關鍵註解與說明文件 (README, Documentation) 預設使用繁體中文說明。
   - 程式碼變數名與語法維持標準英文規範。
4. **Artifacts 與計畫書**：所有產出的 Artifacts (如 implementation_plan.md, walkthrough.md) 必須全篇以繁體中文撰寫。
EOF

if [ -f "$RULE_FILE" ]; then
    echo -e "${GREEN}✓ 全域 AI 規則已設定完畢：${RULE_FILE}${NC}"
else
    echo -e "${YELLOW}! 提示：無法直接寫入家目錄，請手動確認 ~/.gemini/config/rules 權限。${NC}"
fi
echo ""

# 2. 配置 Antigravity IDE UI 繁體中文設定 (settings.json / argv.json)
echo -e "${BLUE}[2/3] 正在配置 Antigravity IDE 繁體中文介面設定...${NC}"

CONFIG_PATHS=(
    "$HOME/Library/Application Support/Antigravity/User"
    "$HOME/Library/Application Support/Code/User"
    "$HOME/.config/antigravity/User"
)

for CONF_DIR in "${CONFIG_PATHS[@]}"; do
    mkdir -p "$CONF_DIR" 2>/dev/null
    
    if [ -d "$CONF_DIR" ]; then
        # 設定 argv.json
        ARGV_FILE="$CONF_DIR/argv.json"
        if [ ! -f "$ARGV_FILE" ]; then
            echo '{"locale": "zh-tw"}' > "$ARGV_FILE" 2>/dev/null
        else
            if grep -q '"locale"' "$ARGV_FILE" 2>/dev/null; then
                sed -i '' 's/"locale": *"[^"]*"/"locale": "zh-tw"/' "$ARGV_FILE" 2>/dev/null
            else
                sed -i '' 's/^{/{\n  "locale": "zh-tw",/' "$ARGV_FILE" 2>/dev/null
            fi
        fi
        
        # 設定 settings.json
        SETTINGS_FILE="$CONF_DIR/settings.json"
        if [ ! -f "$SETTINGS_FILE" ]; then
            cat << 'EOF' > "$SETTINGS_FILE" 2>/dev/null
{
  "antigravity.language": "zh-TW",
  "workbench.preferredLanguage": "zh-tw"
}
EOF
        fi
        echo -e "${GREEN}✓ 已寫入 IDE 語系配置：${CONF_DIR}${NC}"
    fi
done

echo ""

# 3. 安裝繁體中文語言包擴充套件 (Language Pack)
echo -e "${BLUE}[3/3] 正在嘗試安裝 IDE 繁體中文語言包擴充套件...${NC}"

INSTALLED=0
for CMD in antigravity code; do
    if command -v $CMD &> /dev/null; then
        echo -e "${YELLOW}找到 IDE CLI 工具 ($CMD)，正在安裝繁體中文語言包...${NC}"
        $CMD --install-extension MS-CEINTL.vscode-language-pack-zh-hant --force 2>/dev/null && INSTALLED=1
    fi
done

if [ $INSTALLED -eq 0 ]; then
    echo -e "${YELLOW}提示：若 IDE 介面未自動切換，請在 Antigravity IDE 的 Extensions 擴充選單搜尋並安裝「Chinese (Traditional) Language Pack」。${NC}"
fi

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN} 🎉 Antigravity 繁體中文介面與語系設定完成！ ${NC}"
echo -e "${GREEN} 請重啟 Antigravity IDE / App 以套用完整繁體中文介面。${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
read -p "按 Enter 鍵結束安裝程式..."
