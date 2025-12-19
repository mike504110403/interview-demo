#!/bin/bash
# macOS NAT 設置腳本
# 讓 Docker 容器內的 Pritunl VPN 流量能夠轉發到外網

set -e

echo "=== 配置 macOS NAT for Pritunl VPN ==="

# 1. 啟用 IP forwarding
echo "1. 啟用 IP forwarding..."
sudo sysctl -w net.inet.ip.forwarding=1

# 2. 獲取主要網路介面（通常是 en0）
INTERFACE=$(route -n get default | grep 'interface:' | awk '{print $2}')
echo "2. 檢測到網路介面: $INTERFACE"

# 3. 創建 pf 規則文件
PF_CONF="/tmp/pritunl-pf.conf"
echo "3. 創建 pf 規則..."
cat > "$PF_CONF" <<EOF
# Pritunl VPN NAT 規則
# 允許 Docker 網路 (172.25.0.0/16) 的流量通過主機轉發到外網

# NAT 規則：將 Docker 網路的流量偽裝成主機 IP
nat on $INTERFACE from 172.25.0.0/16 to any -> ($INTERFACE)

# 允許轉發規則
pass in on bridge0 from 172.25.0.0/16 to any keep state
pass out on $INTERFACE from 172.25.0.0/16 to any keep state
EOF

echo "4. 載入 pf 規則..."
# 先檢查 pf 是否啟用
if sudo pfctl -s info | grep -q "Status: Enabled"; then
    echo "   pf 已啟用，添加規則..."
    sudo pfctl -f "$PF_CONF"
else
    echo "   啟用 pf 並載入規則..."
    sudo pfctl -e -f "$PF_CONF"
fi

echo ""
echo "✅ NAT 配置完成！"
echo ""
echo "測試步驟："
echo "1. 讓同事重新連接 VPN"
echo "2. 測試訪問 test.dev"
echo "3. 測試訪問外網（如 google.com）"
echo ""
echo "如果要停用 NAT："
echo "  sudo pfctl -d  # 停用 pf"
echo "  sudo sysctl -w net.inet.ip.forwarding=0  # 停用 IP forwarding"
