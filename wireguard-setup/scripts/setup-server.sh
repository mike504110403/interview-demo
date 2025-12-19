#!/bin/bash

# WireGuard Server 初始化腳本
# 用途：在 Server 上安裝和配置 WireGuard

set -e

echo "🚀 WireGuard Server 初始化..."
echo "================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 檢查是否為 root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 請使用 sudo 執行此腳本${NC}"
    exit 1
fi

# 配置變數
SERVER_DIR="../server"
WG_INTERFACE="wg0"
WG_PORT="51820"
WG_NET="10.0.0.0/24"
SERVER_IP="10.0.0.1/24"

# 偵測公網 IP（如果在雲端伺服器）
echo -e "${YELLOW}📡 偵測公網 IP...${NC}"
PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "YOUR_SERVER_IP")
echo -e "${GREEN}公網 IP: ${PUBLIC_IP}${NC}"

# 步驟 1: 安裝 WireGuard
echo ""
echo -e "${YELLOW}步驟 1: 安裝 WireGuard${NC}"

if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    echo "偵測到 Ubuntu/Debian 系統"
    apt-get update
    apt-get install -y wireguard wireguard-tools dnsmasq
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    echo "偵測到 CentOS/RHEL 系統"
    yum install -y epel-release
    yum install -y wireguard-tools dnsmasq
elif command -v brew &> /dev/null; then
    # macOS
    echo "偵測到 macOS 系統"
    brew install wireguard-tools dnsmasq
else
    echo -e "${RED}❌ 無法識別的系統，請手動安裝 WireGuard${NC}"
    exit 1
fi

echo -e "${GREEN}✅ WireGuard 安裝完成${NC}"

# 步驟 2: 建立配置目錄
echo ""
echo -e "${YELLOW}步驟 2: 建立配置目錄${NC}"

mkdir -p ${SERVER_DIR}
cd ${SERVER_DIR}

# 步驟 3: 生成 Server 金鑰
echo ""
echo -e "${YELLOW}步驟 3: 生成 Server 金鑰${NC}"

if [ -f "server_private.key" ]; then
    echo -e "${YELLOW}⚠️  Server 金鑰已存在，跳過生成${NC}"
else
    wg genkey | tee server_private.key | wg pubkey > server_public.key
    chmod 600 server_private.key
    echo -e "${GREEN}✅ Server 金鑰生成完成${NC}"
fi

SERVER_PRIVATE_KEY=$(cat server_private.key)
SERVER_PUBLIC_KEY=$(cat server_public.key)

echo -e "${GREEN}Server Public Key: ${SERVER_PUBLIC_KEY}${NC}"

# 步驟 4: 生成 Server 配置
echo ""
echo -e "${YELLOW}步驟 4: 生成 Server 配置${NC}"

cat > wg0.conf << EOF
# WireGuard Server 配置
# 生成時間: $(date)

[Interface]
# Server 的私鑰
PrivateKey = ${SERVER_PRIVATE_KEY}

# Server 的內網 IP
Address = ${SERVER_IP}

# 監聽端口
ListenPort = ${WG_PORT}

# 啟動時執行的命令
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -A FORWARD -o %i -j ACCEPT
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -D FORWARD -o %i -j ACCEPT

# DNS Server (Server 自己)
# Client 會使用這個 DNS
# DNS = ${SERVER_IP%/*}

# ============================================
# Client 配置區（使用 add-client.sh 新增）
# ============================================

EOF

echo -e "${GREEN}✅ Server 配置生成完成: ${SERVER_DIR}/wg0.conf${NC}"

# 步驟 5: 啟用 IP 轉發
echo ""
echo -e "${YELLOW}步驟 5: 啟用 IP 轉發${NC}"

# 臨時啟用
sysctl -w net.ipv4.ip_forward=1

# 永久啟用
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

echo -e "${GREEN}✅ IP 轉發已啟用${NC}"

# 步驟 6: 配置防火牆
echo ""
echo -e "${YELLOW}步驟 6: 配置防火牆${NC}"

if command -v ufw &> /dev/null; then
    # UFW (Ubuntu)
    ufw allow ${WG_PORT}/udp
    echo -e "${GREEN}✅ UFW 規則已新增${NC}"
elif command -v firewall-cmd &> /dev/null; then
    # firewalld (CentOS)
    firewall-cmd --permanent --add-port=${WG_PORT}/udp
    firewall-cmd --reload
    echo -e "${GREEN}✅ firewalld 規則已新增${NC}"
else
    echo -e "${YELLOW}⚠️  請手動開放 ${WG_PORT}/udp 端口${NC}"
fi

# 步驟 7: 配置內部 DNS (dnsmasq)
echo ""
echo -e "${YELLOW}步驟 7: 配置內部 DNS${NC}"

# 備份原始配置
if [ -f "/etc/dnsmasq.conf" ]; then
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup
fi

# 創建自定義配置
cat > /etc/dnsmasq.d/wireguard.conf << EOF
# WireGuard 內部 DNS 配置
# 生成時間: $(date)

# 監聽介面
interface=${WG_INTERFACE}

# 不轉發沒有點的域名
domain-needed

# 不轉發私有 IP 的反向查詢
bogus-priv

# 內部域名解析
# 格式: address=/域名/IP

# 核心服務
address=/gitlab.internal/10.0.1.10

# 開發環境
address=/dev.internal/10.0.2.10
address=/dev-api.internal/10.0.2.10
address=/dev-web.internal/10.0.2.20

# 測試環境
address=/staging.internal/10.0.3.10
address=/staging-api.internal/10.0.3.10
address=/staging-web.internal/10.0.3.20

# 文檔
address=/docs.internal/10.0.4.10

# 監控
address=/grafana.internal/10.0.5.10
address=/prometheus.internal/10.0.5.20
address=/kibana.internal/10.0.5.40

# 其他域名轉發到公共 DNS
server=8.8.8.8
server=8.8.4.4
EOF

# 重啟 dnsmasq
systemctl enable dnsmasq
systemctl restart dnsmasq

echo -e "${GREEN}✅ DNS 配置完成${NC}"

# 步驟 8: 複製配置到系統目錄
echo ""
echo -e "${YELLOW}步驟 8: 安裝配置檔案${NC}"

cp wg0.conf /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/wg0.conf

echo -e "${GREEN}✅ 配置檔案已安裝到 /etc/wireguard/wg0.conf${NC}"

# 完成
echo ""
echo "================================"
echo -e "${GREEN}🎉 WireGuard Server 初始化完成！${NC}"
echo ""
echo "📋 Server 資訊："
echo "  - 公網 IP: ${PUBLIC_IP}"
echo "  - 內網 IP: ${SERVER_IP}"
echo "  - 監聽端口: ${WG_PORT}"
echo "  - Public Key: ${SERVER_PUBLIC_KEY}"
echo ""
echo "📝 下一步："
echo "  1. 使用 add-client.sh 新增 Client 配置"
echo "     ./add-client.sh engineer_a"
echo ""
echo "  2. 啟動 WireGuard Server"
echo "     sudo wg-quick up wg0"
echo ""
echo "  3. 設定開機自動啟動"
echo "     sudo systemctl enable wg-quick@wg0"
echo ""
echo "  4. 檢查狀態"
echo "     sudo wg show"
echo ""

# 儲存資訊到檔案
cat > server_info.txt << EOF
WireGuard Server 資訊
生成時間: $(date)
==================================

公網 IP: ${PUBLIC_IP}
內網 IP: ${SERVER_IP}
監聽端口: ${WG_PORT}
Public Key: ${SERVER_PUBLIC_KEY}

配置檔案: /etc/wireguard/wg0.conf

啟動命令:
  sudo wg-quick up wg0
  sudo systemctl enable wg-quick@wg0

檢查狀態:
  sudo wg show

內部域名解析:
  gitlab.internal     -> 10.0.1.10
  dev.internal        -> 10.0.2.10
  staging.internal    -> 10.0.3.10
  docs.internal       -> 10.0.4.10
  grafana.internal    -> 10.0.5.10

==================================
EOF

echo -e "${GREEN}✅ Server 資訊已儲存到 server_info.txt${NC}"
