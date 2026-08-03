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
GEMINI_DIR="$HOME/.gemini/config"
RULE_DIR="$GEMINI_DIR/rules"
mkdir -p "$RULE_DIR" 2>/dev/null

cat << 'EOF' > "$GEMINI_DIR/GEMINI.md" 2>/dev/null
# 繁體中文對話與回應規範 (Traditional Chinese Rule)

- **主要語言**：所有 AI Agent 的對話、說明、提示、分析報告、計畫書及文檔輸出，必須一律使用 **正體 / 繁體中文** (Taiwan / Traditional Chinese)。
- **專業術語**：請使用臺灣與繁體中文標準用語（例如：程式碼、專案、伺服器、數據/資料、網路、執行檔、函式/函數、模組等）。
- **計畫書與報告**：所有產出的 Artifacts (如 implementation_plan.md, walkthrough.md) 必須全篇以繁體中文撰寫。
EOF

cp "$GEMINI_DIR/GEMINI.md" "$GEMINI_DIR/AGENTS.md" 2>/dev/null
cp "$GEMINI_DIR/GEMINI.md" "$RULE_DIR/traditional_chinese.md" 2>/dev/null

echo -e "${GREEN}✓ 全域 AI 規則已設定完畢：${GEMINI_DIR}/GEMINI.md${NC}"
echo ""

# 2. 配置 Antigravity IDE UI 繁體中文設定 (locale.json / argv.json / settings.json)
echo -e "${BLUE}[2/3] 正在配置 Antigravity IDE 繁體中文介面設定...${NC}"

CONFIG_PATHS=(
    "$HOME/Library/Application Support/Antigravity/User"
    "$HOME/Library/Application Support/Code/User"
    "$HOME/.config/antigravity/User"
)

for CONF_DIR in "${CONFIG_PATHS[@]}"; do
    mkdir -p "$CONF_DIR" 2>/dev/null
    
    if [ -d "$CONF_DIR" ]; then
        # 設定 locale.json
        echo '{"locale": "zh-tw"}' > "$CONF_DIR/locale.json" 2>/dev/null
        
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
    echo -e "${YELLOW}提示：若選單未自動變更中文，請在 IDE 中按下 Cmd+Shift+P 搜尋「Configure Display Language」選取「zh-tw (繁體中文)」。${NC}"
fi

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN} 🎉 Antigravity 繁體中文介面與語系設定完成！ ${NC}"
echo -e "${GREEN} 請完全關閉並重啟 Antigravity IDE / App 以套用變更。${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
read -p "按 Enter 鍵結束安裝程式..."
