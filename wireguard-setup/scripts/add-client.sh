#!/bin/bash

# 新增 WireGuard Client 配置腳本
# 用途：為新員工生成 VPN 配置檔案

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 檢查參數
if [ -z "$1" ]; then
    echo -e "${RED}❌ 錯誤: 請提供 Client 名稱${NC}"
    echo ""
    echo "用法: $0 <client_name> [ip_suffix]"
    echo ""
    echo "範例:"
    echo "  $0 engineer_a          # 自動分配 IP"
    echo "  $0 engineer_a 25       # 指定 IP 為 10.0.0.25"
    echo ""
    exit 1
fi

CLIENT_NAME=$1
IP_SUFFIX=$2

# 配置變數
SERVER_DIR="../server"
CLIENTS_DIR="../clients"
SERVER_PUBLIC_KEY=$(cat ${SERVER_DIR}/server_public.key)
SERVER_ENDPOINT="YOUR_SERVER_IP:51820"  # 需要替換為實際的 Server IP

# 讀取 server_info.txt 取得 Server IP（如果存在）
if [ -f "${SERVER_DIR}/server_info.txt" ]; then
    SERVER_IP=$(grep "公網 IP:" ${SERVER_DIR}/server_info.txt | awk '{print $3}')
    if [ -n "$SERVER_IP" ] && [ "$SERVER_IP" != "YOUR_SERVER_IP" ]; then
        SERVER_ENDPOINT="${SERVER_IP}:51820"
    fi
fi

echo "🔑 為 ${CLIENT_NAME} 生成 VPN 配置..."
echo "================================"

# 建立 clients 目錄
mkdir -p ${CLIENTS_DIR}

# 檢查 Client 是否已存在
if [ -f "${CLIENTS_DIR}/${CLIENT_NAME}.conf" ]; then
    echo -e "${YELLOW}⚠️  Client ${CLIENT_NAME} 已存在${NC}"
    read -p "是否要重新生成？ (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# 生成 Client 金鑰
echo ""
echo -e "${YELLOW}步驟 1: 生成 Client 金鑰${NC}"

CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo ${CLIENT_PRIVATE_KEY} | wg pubkey)

echo -e "${GREEN}✅ 金鑰生成完成${NC}"
echo "Public Key: ${CLIENT_PUBLIC_KEY}"

# 分配 IP
echo ""
echo -e "${YELLOW}步驟 2: 分配內網 IP${NC}"

if [ -z "$IP_SUFFIX" ]; then
    # 自動分配 IP：查找下一個可用的 IP
    LAST_IP=$(grep -oP 'AllowedIPs = 10\.0\.0\.\K\d+' ${SERVER_DIR}/wg0.conf 2>/dev/null | sort -n | tail -1)
    if [ -z "$LAST_IP" ]; then
        IP_SUFFIX=10  # 從 10 開始
    else
        IP_SUFFIX=$((LAST_IP + 1))
    fi
fi

CLIENT_IP="10.0.0.${IP_SUFFIX}/32"
CLIENT_IP_DISPLAY="10.0.0.${IP_SUFFIX}/24"

echo -e "${GREEN}✅ 分配 IP: ${CLIENT_IP_DISPLAY}${NC}"

# 生成 Client 配置檔案
echo ""
echo -e "${YELLOW}步驟 3: 生成 Client 配置${NC}"

cat > ${CLIENTS_DIR}/${CLIENT_NAME}.conf << EOF
# WireGuard Client 配置
# 使用者: ${CLIENT_NAME}
# 生成時間: $(date)

[Interface]
# Client 的私鑰（請妥善保管，不要洩漏）
PrivateKey = ${CLIENT_PRIVATE_KEY}

# Client 的內網 IP
Address = ${CLIENT_IP_DISPLAY}

# 使用 VPN Server 作為 DNS
DNS = 10.0.0.1

[Peer]
# Server 的公鑰
PublicKey = ${SERVER_PUBLIC_KEY}

# Server 的公網地址和端口
Endpoint = ${SERVER_ENDPOINT}

# 允許的 IP 範圍（路由到 VPN 的流量）
# 10.0.0.0/16 = 所有內網流量都走 VPN
AllowedIPs = 10.0.0.0/16

# 保持連線（NAT 穿透）
PersistentKeepalive = 25
EOF

echo -e "${GREEN}✅ Client 配置已生成: ${CLIENTS_DIR}/${CLIENT_NAME}.conf${NC}"

# 更新 Server 配置
echo ""
echo -e "${YELLOW}步驟 4: 更新 Server 配置${NC}"

# 檢查是否已經存在該 Client 的配置
if grep -q "# Client: ${CLIENT_NAME}" ${SERVER_DIR}/wg0.conf; then
    # 移除舊的配置
    sed -i.bak "/# Client: ${CLIENT_NAME}/,/^$/d" ${SERVER_DIR}/wg0.conf
fi

# 添加新的 Peer 配置
cat >> ${SERVER_DIR}/wg0.conf << EOF

# Client: ${CLIENT_NAME}
# 生成時間: $(date)
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}

EOF

echo -e "${GREEN}✅ Server 配置已更新${NC}"

# 重新載入 Server 配置（如果 Server 正在運行）
echo ""
echo -e "${YELLOW}步驟 5: 重新載入 Server 配置${NC}"

if sudo wg show wg0 &> /dev/null; then
    echo "偵測到 WireGuard 正在運行，重新載入配置..."
    
    # 複製更新後的配置到系統目錄
    sudo cp ${SERVER_DIR}/wg0.conf /etc/wireguard/wg0.conf
    
    # 重新啟動 WireGuard
    sudo wg-quick down wg0 2>/dev/null || true
    sudo wg-quick up wg0
    
    echo -e "${GREEN}✅ Server 配置已重新載入${NC}"
else
    echo -e "${YELLOW}⚠️  WireGuard Server 未運行，配置已更新但未載入${NC}"
    echo "請手動啟動: sudo wg-quick up wg0"
fi

# 生成 QR Code（給手機使用，可選）
echo ""
echo -e "${YELLOW}步驟 6: 生成 QR Code (可選)${NC}"

if command -v qrencode &> /dev/null; then
    qrencode -t ansiutf8 < ${CLIENTS_DIR}/${CLIENT_NAME}.conf
    echo -e "${GREEN}✅ QR Code 已生成（手機掃描即可使用）${NC}"
else
    echo -e "${YELLOW}💡 提示: 安裝 qrencode 可以生成 QR Code${NC}"
    echo "   sudo apt install qrencode"
fi

# 生成使用說明
cat > ${CLIENTS_DIR}/${CLIENT_NAME}_instructions.txt << EOF
WireGuard VPN 使用說明
使用者: ${CLIENT_NAME}
生成時間: $(date)
==================================

您的 VPN 配置資訊：
- 內網 IP: ${CLIENT_IP_DISPLAY}
- VPN Server: ${SERVER_ENDPOINT}

==================================
安裝步驟：
==================================

【Windows】
1. 下載 WireGuard: https://www.wireguard.com/install/
2. 安裝並啟動 WireGuard
3. 點擊 "Add Tunnel" → "Import from file"
4. 選擇 ${CLIENT_NAME}.conf
5. 點擊 "Activate" 啟動連線

【macOS】
1. 下載 WireGuard: https://apps.apple.com/us/app/wireguard/id1451685025
2. 打開 WireGuard App
3. 點擊 "Import tunnel from file"
4. 選擇 ${CLIENT_NAME}.conf
5. 點擊啟動開關

【Linux】
1. 安裝: sudo apt install wireguard
2. 複製配置: sudo cp ${CLIENT_NAME}.conf /etc/wireguard/
3. 啟動: sudo wg-quick up ${CLIENT_NAME}
4. 開機啟動: sudo systemctl enable wg-quick@${CLIENT_NAME}

【iOS / Android】
1. 安裝 WireGuard App
2. 掃描 QR Code 或手動導入配置

==================================
連線測試：
==================================

連接 VPN 後，執行以下命令測試：

# 1. 測試 VPN Gateway
ping 10.0.0.1

# 2. 測試內部域名解析
ping gitlab.internal

# 3. 測試內部服務（如果已部署）
curl http://dev.internal:8080

==================================
內部服務域名：
==================================

gitlab.internal     -> 10.0.1.10  (GitLab)
dev.internal        -> 10.0.2.10  (開發環境)
staging.internal    -> 10.0.3.10  (測試環境)
docs.internal       -> 10.0.4.10  (文檔系統)
grafana.internal    -> 10.0.5.10  (監控面板)

==================================
注意事項：
==================================

1. 🔐 配置檔案包含私鑰，請妥善保管
2. ❌ 不要分享給其他人
3. 📱 可以在多個設備上使用同一配置
4. 🔄 離職時配置會被撤銷
5. ⚠️  遇到問題請聯繫 IT 部門

==================================
EOF

echo -e "${GREEN}✅ 使用說明已生成: ${CLIENTS_DIR}/${CLIENT_NAME}_instructions.txt${NC}"

# 完成
echo ""
echo "================================"
echo -e "${GREEN}🎉 Client 配置生成完成！${NC}"
echo ""
echo "📋 Client 資訊："
echo "  - 使用者: ${CLIENT_NAME}"
echo "  - 內網 IP: ${CLIENT_IP_DISPLAY}"
echo "  - Public Key: ${CLIENT_PUBLIC_KEY}"
echo ""
echo "📁 生成的檔案："
echo "  - 配置檔: ${CLIENTS_DIR}/${CLIENT_NAME}.conf"
echo "  - 使用說明: ${CLIENTS_DIR}/${CLIENT_NAME}_instructions.txt"
echo ""
echo "📤 下一步："
echo "  1. 將 ${CLIENT_NAME}.conf 安全地發送給員工"
echo "  2. 員工安裝 WireGuard Client"
echo "  3. 導入配置檔案"
echo "  4. 啟動連線並測試"
echo ""
echo "💡 提示："
echo "  - 可以用 Email 加密傳送配置"
echo "  - 或讓員工當面拷貝到 USB"
echo "  - 手機用戶可以掃描 QR Code"
echo ""
