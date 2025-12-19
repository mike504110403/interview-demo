# WireGuard VPN 實戰教學

## 🎯 目標

建立一個 WireGuard VPN Server，讓員工可以：
1. 連接 VPN 獲得內網 IP
2. 使用自定義域名（如 `gitlab.internal`）
3. 自動解析到內網服務

## 📋 環境準備

### Server 端（VPN Gateway）
- 作業系統：Ubuntu 22.04 或 macOS
- 需要：公網 IP 或固定 IP
- 端口：51820/UDP

### Client 端（員工電腦）
- 支援：Windows / macOS / Linux / iOS / Android
- 只需安裝 WireGuard Client

---

## 🚀 快速開始（5 步驟）

### 步驟 1: Server 安裝 WireGuard

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install wireguard
```

**macOS:**
```bash
brew install wireguard-tools
```

### 步驟 2: 生成 Server 配置

```bash
# 執行我們準備的腳本
cd wireguard-setup/scripts
chmod +x setup-server.sh
sudo ./setup-server.sh
```

### 步驟 3: 生成 Client 配置

```bash
# 為員工生成配置
./add-client.sh engineer_a
./add-client.sh designer_b

# 配置文件會在 ../clients/ 資料夾
```

### 步驟 4: 啟動 Server

```bash
sudo wg-quick up wg0
```

### 步驟 5: Client 連接

1. 將 `clients/engineer_a.conf` 發送給員工
2. 員工安裝 WireGuard Client
3. 導入配置文件
4. 點擊連接！

---

## 📁 檔案結構

```
wireguard-setup/
├── README.md                    # 本文件
├── server/
│   ├── wg0.conf                # Server 配置（自動生成）
│   ├── server_private.key      # Server 私鑰
│   └── server_public.key       # Server 公鑰
├── clients/
│   ├── engineer_a.conf         # 員工 A 的配置
│   ├── designer_b.conf         # 設計師 B 的配置
│   └── ...
└── scripts/
    ├── setup-server.sh         # Server 初始化腳本
    ├── add-client.sh           # 新增客戶端腳本
    ├── remove-client.sh        # 移除客戶端腳本
    └── list-clients.sh         # 列出所有客戶端
```

---

## 🔍 測試流程

### 1. Server 端測試

```bash
# 檢查 WireGuard 狀態
sudo wg show

# 應該看到：
# interface: wg0
#   public key: <server_public_key>
#   private key: (hidden)
#   listening port: 51820
```

### 2. Client 端連接

```bash
# macOS/Linux
sudo wg-quick up engineer_a

# 或使用 GUI 客戶端直接導入 .conf 文件
```

### 3. 驗證連接

```bash
# Client 端執行
ping 10.0.0.1  # VPN Gateway

# 如果 ping 通，代表 VPN 連接成功！
```

### 4. 測試內部域名

```bash
# Client 端執行
ping gitlab.internal
# 應該解析到 10.0.1.10

curl http://dev.internal:8080
# 應該能存取內部服務
```

---

## 🌐 DNS 配置說明

### VPN Server 提供 DNS

```bash
# 在 wg0.conf 中配置
[Interface]
Address = 10.0.0.1/24
DNS = 10.0.0.1  # ← VPN Server 自己當 DNS
```

### 自定義域名解析

**方法 1: 使用 dnsmasq（推薦）**
```bash
# 安裝 dnsmasq
sudo apt install dnsmasq

# 配置 /etc/dnsmasq.conf
address=/gitlab.internal/10.0.1.10
address=/dev.internal/10.0.2.10
address=/staging.internal/10.0.3.10

# 重啟
sudo systemctl restart dnsmasq
```

**方法 2: 直接修改 /etc/hosts（簡單但功能有限）**
```bash
# /etc/hosts
10.0.1.10  gitlab.internal
10.0.2.10  dev.internal
10.0.3.10  staging.internal
```

Client 會自動使用 VPN Server 的 DNS，因此可以解析這些域名！

---

## 📊 IP 規劃

```
VPN 網段: 10.0.0.0/24
├── 10.0.0.1      VPN Gateway (Server)
├── 10.0.0.10-19  管理層
├── 10.0.0.20-99  工程師
└── 10.0.0.100+   其他人員

內部服務網段: 10.0.1.0 - 10.0.255.0
├── 10.0.1.x      核心服務 (GitLab)
├── 10.0.2.x      開發環境
├── 10.0.3.x      測試環境
└── 10.0.5.x      監控服務
```

---

## 🔐 安全最佳實踐

1. **私鑰保護**
   - Server 私鑰：只存在 Server 上
   - Client 私鑰：只給該員工，不上傳

2. **定期輪替**
   - 每季度重新生成金鑰
   - 離職員工立即撤銷配置

3. **監控連線**
   - 定期檢查 `wg show`
   - 記錄連線日誌

---

## 🐛 常見問題

### Q1: Client 無法連接？

```bash
# 檢查 Server 防火牆
sudo ufw allow 51820/udp

# 檢查 Server 是否在運行
sudo wg show

# 檢查 IP 轉發是否啟用
cat /proc/sys/net/ipv4/ip_forward  # 應該是 1
```

### Q2: 能 ping 通 VPN Gateway，但無法存取內部服務？

```bash
# 檢查路由
ip route

# 檢查內部服務的防火牆
# 確保內部服務允許來自 10.0.0.0/24 的流量
```

### Q3: DNS 無法解析內部域名？

```bash
# Client 檢查 DNS 設定
cat /etc/resolv.conf
# 應該包含 nameserver 10.0.0.1

# Server 檢查 dnsmasq 是否運行
sudo systemctl status dnsmasq
```

---

## 📖 詳細步驟

請參考：
- `scripts/setup-server.sh` - Server 完整安裝腳本
- `scripts/add-client.sh` - Client 配置生成腳本
- Server 端詳細配置說明
- Client 端詳細配置說明

---

## 🎓 下一步

1. ✅ 建立 VPN 連接
2. ✅ 設定內部 DNS
3. ⬜ 部署內部服務（GitLab 等）
4. ⬜ 配置防火牆規則
5. ⬜ 建立監控系統

開始測試吧！🚀
