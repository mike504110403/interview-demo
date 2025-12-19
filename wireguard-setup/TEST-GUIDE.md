# 🧪 WireGuard 測試指南

## 📋 測試環境說明

### 方案 A: 本機測試（推薦新手）

```
場景：在同一台 Mac 上測試
- VPN Server: 本機
- VPN Client: 本機
- 目的：驗證配置正確性
```

### 方案 B: 實際環境測試

```
場景：跨機器測試
- VPN Server: 一台 Mac 或雲端伺服器
- VPN Client: 另一台電腦/手機
- 目的：實際使用場景
```

---

## 🚀 方案 A: 本機快速測試

### 步驟 1: 安裝 WireGuard

```bash
# macOS
brew install wireguard-tools

# 驗證安裝
wg --version
```

### 步驟 2: 準備測試環境

```bash
cd /Users/mike/Documents/self/interview-demo/wireguard-setup

# 設定腳本執行權限
chmod +x scripts/*.sh
```

### 步驟 3: 初始化 Server

```bash
# 執行 Server 設定腳本
cd scripts
sudo ./setup-server.sh

# 等待腳本完成...
# 會在 ../server/ 生成配置檔案
```

### 步驟 4: 生成 Client 配置

```bash
# 為自己生成一個測試配置
./add-client.sh test_user

# 配置會在 ../clients/test_user.conf
```

### 步驟 5: 啟動 Server

```bash
# 啟動 WireGuard Server
sudo wg-quick up wg0

# 檢查狀態
sudo wg show

# 應該看到：
# interface: wg0
#   public key: <key>
#   private key: (hidden)
#   listening port: 51820
#
#   peer: <client_public_key>
#     allowed ips: 10.0.0.10/32
```

### 步驟 6: 啟動 Client（新終端機）

```bash
# 打開新的終端機視窗

# 啟動 Client
cd /Users/mike/Documents/self/interview-demo/wireguard-setup/clients
sudo wg-quick up test_user

# 或使用絕對路徑
sudo wg-quick up /Users/mike/Documents/self/interview-demo/wireguard-setup/clients/test_user.conf
```

### 步驟 7: 測試連線

```bash
# 在 Client 終端機測試

# 1. 測試 VPN Gateway
ping -c 4 10.0.0.1

# 2. 檢查 Client IP
ifconfig utun3  # macOS 的 WireGuard 介面
# 應該看到 inet 10.0.0.10

# 3. 測試內部域名（需要先設定 DNS）
ping gitlab.internal
```

### 步驟 8: 清理

```bash
# 停止 Client
sudo wg-quick down test_user

# 停止 Server
sudo wg-quick down wg0
```

---

## 🌐 方案 B: 實際環境測試

### 準備工作

**Server 端（雲端伺服器或一台 Mac）：**
- 有固定公網 IP 或可透過路由器端口轉發
- 開放 51820/UDP 端口

**Client 端（另一台電腦）：**
- 安裝 WireGuard Client

### Server 端設定

```bash
# 1. SSH 登入到 Server
ssh user@your-server-ip

# 2. 下載腳本
git clone <your-repo> 或手動複製腳本

# 3. 執行設定
cd wireguard-setup/scripts
sudo ./setup-server.sh

# 4. 記錄 Server 資訊
cat ../server/server_info.txt

# 5. 生成 Client 配置
./add-client.sh mike_laptop

# 6. 啟動 Server
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0  # 開機自動啟動
```

### Client 端設定

```bash
# 1. 從 Server 下載配置（安全方式）
scp user@server-ip:/path/to/clients/mike_laptop.conf ~/

# 2. 安裝 WireGuard
# macOS: brew install wireguard-tools
# Windows: https://www.wireguard.com/install/
# Linux: sudo apt install wireguard

# 3. 啟動連線
sudo wg-quick up ~/mike_laptop.conf

# 4. 測試連線
ping 10.0.0.1
```

---

## 🧪 完整測試清單

### ✅ 基礎連線測試

```bash
# 1. VPN 連線測試
ping -c 4 10.0.0.1
# ✅ 如果能 ping 通，代表 VPN 連接成功

# 2. 檢查路由
ip route | grep 10.0.0.0
# 或 macOS
netstat -nr | grep 10.0.0

# 3. 檢查 DNS
cat /etc/resolv.conf
# 應該看到 nameserver 10.0.0.1
```

### ✅ 內部域名測試

```bash
# 1. 測試域名解析
nslookup gitlab.internal 10.0.0.1
# 應該返回 10.0.1.10

# 2. Ping 測試
ping -c 4 gitlab.internal

# 3. 列出所有內部域名
cat /etc/dnsmasq.d/wireguard.conf | grep address
```

### ✅ 模擬內部服務測試

在沒有實際服務的情況下，可以用 Python 快速建立測試服務：

```bash
# 在 Server 端啟動測試服務

# 模擬 GitLab (10.0.1.10:80)
python3 -m http.server 8080 --bind 10.0.1.10 &

# 模擬 Dev (10.0.2.10:8080)
python3 -m http.server 8080 --bind 10.0.2.10 &

# 從 Client 測試
curl http://10.0.1.10:8080
curl http://gitlab.internal:8080  # 如果 DNS 正確設定
```

### ✅ 安全性測試

```bash
# 1. 測試直接存取被阻擋
# 從外網嘗試存取內部 IP（應該失敗）
ping 10.0.1.10  # 在未連 VPN 的機器上
# ❌ 應該無法連接

# 2. 測試 VPN 斷線
sudo wg-quick down wg0
ping 10.0.0.1
# ❌ 應該無法連接

# 3. 測試權限隔離
# 嘗試存取不在 AllowedIPs 的網段
ping 192.168.1.1
# 應該不經過 VPN
```

### ✅ 效能測試

```bash
# 1. 測試延遲
ping -c 100 10.0.0.1 | tail -1
# 應該 < 50ms

# 2. 測試頻寬
# 安裝 iperf3
brew install iperf3

# Server 端
iperf3 -s -B 10.0.0.1

# Client 端
iperf3 -c 10.0.0.1
```

---

## 🔧 故障排除

### 問題 1: Client 無法連接

```bash
# 檢查 Server 是否運行
sudo wg show

# 檢查防火牆
sudo ufw status  # Ubuntu
sudo pfctl -s rules  # macOS

# 檢查端口
sudo lsof -i :51820

# 查看日誌
sudo journalctl -u wg-quick@wg0 -f  # Linux
sudo dmesg | grep wireguard  # macOS
```

### 問題 2: 連上 VPN 但無法存取內部服務

```bash
# 檢查路由
ip route show table all | grep 10.0.0.0

# 檢查 IP 轉發
cat /proc/sys/net/ipv4/ip_forward  # 應該是 1

# 檢查 iptables
sudo iptables -L -v -n
sudo iptables -t nat -L -v -n
```

### 問題 3: DNS 無法解析內部域名

```bash
# 檢查 DNS 設定
cat /etc/resolv.conf

# 手動測試 DNS
nslookup gitlab.internal 10.0.0.1
dig @10.0.0.1 gitlab.internal

# 檢查 dnsmasq
sudo systemctl status dnsmasq
sudo journalctl -u dnsmasq -f
```

### 問題 4: macOS 權限問題

```bash
# 如果遇到 "Operation not permitted"
# 需要給予終端機完整磁碟存取權限
# 系統偏好設定 → 安全性與隱私 → 隱私權 → 完整磁碟取用權限
# 新增終端機 App
```

---

## 📊 測試結果記錄

建立測試記錄檔：

```bash
cat > test_results.txt << EOF
WireGuard 測試結果
測試時間: $(date)
==================================

✅ VPN 連線測試
- Server IP: 可達
- Client IP: 10.0.0.10
- 延遲: <delay>ms

✅ DNS 測試
- gitlab.internal: 10.0.1.10
- dev.internal: 10.0.2.10

✅ 內部服務測試
- GitLab: 可存取
- Dev Env: 可存取

✅ 安全性測試
- 外網隔離: 正常
- VPN 斷線保護: 正常

==================================
EOF
```

---

## 🎯 下一步

測試通過後：

1. ✅ 為實際員工生成配置
2. ✅ 部署實際的內部服務（GitLab 等）
3. ✅ 配置監控和日誌
4. ✅ 建立備份機制
5. ✅ 編寫操作手冊

恭喜！您的 VPN 基礎架構已經就緒 🎉
