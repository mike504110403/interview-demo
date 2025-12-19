# VPN Gateway 解決方案比較

## 當前問題
Pritunl 在 Docker 橋接網路內，無法正確轉發 VPN 流量到外網其他機器。

---

## 🎯 **方案 1：Netmaker（推薦用於生產環境）**

### 特點
- ✅ **完整的 WireGuard 管理平台**
- ✅ **內建 Gateway/Egress 功能**（專門處理你要的場景）
- ✅ **零信任網路架構**
- ✅ **支援 ACL、用戶管理**
- ✅ **完整的 Web UI**
- ✅ **開源（Community Edition）**

### 適用場景
```
員工 → Netmaker VPN → Gateway Node → 外網服務
                                    ↓
                              只允許 Gateway IP
```

### Docker Compose
```yaml
version: "3.8"
services:
  netmaker:
    image: gravitl/netmaker:latest
    container_name: netmaker
    environment:
      SERVER_HOST: "192.168.68.106"
      MASTER_KEY: "your-secure-key"
      DATABASE: "sqlite"
    volumes:
      - netmaker-data:/root/data
    network_mode: host  # 使用主機網路，NAT 自動工作
    restart: unless-stopped

volumes:
  netmaker-data:
```

**優點**：專門為企業 VPN Gateway 設計
**缺點**：需要重新設置（但更適合你的需求）

---

## 🎯 **方案 2：Pritunl + Host 網路模式**

### 修改現有配置
保留 Pritunl，但改用 `network_mode: host`：

```yaml
services:
  pritunl:
    image: ghcr.io/jippi/docker-pritunl:latest
    network_mode: host  # 直接使用主機網路
    privileged: true
    environment:
      PRITUNL_MONGODB_URI: "mongodb://127.0.0.1:27017/pritunl"
    volumes:
      - pritunl-data:/var/lib/pritunl

  mongodb:
    image: mongo:4.4
    network_mode: host  # 也要用 host 模式
```

**優點**：最簡單，NAT 自動工作
**缺點**：
- 失去 Docker 網路隔離
- 端口直接暴露在主機
- dnsmasq 需要調整

---

## 🎯 **方案 3：使用 VPN Router 容器**

使用專門的 NAT Gateway 容器：

### a) **linuxserver/wireguard** (推薦)
```yaml
version: "3.8"
services:
  wireguard:
    image: linuxserver/wireguard:latest
    container_name: wireguard-gateway
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - PEERS=10  # 可連接的客戶端數
      - INTERNAL_SUBNET=10.13.13.0/24
    volumes:
      - ./wireguard:/config
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    network_mode: host
    restart: unless-stopped
```

**優點**：
- 輕量級
- NAT 自動配置
- 配置簡單

---

## 🎯 **方案 4：OpenVPN-AS (官方版)**

Pritunl 的對手，官方 OpenVPN Access Server：

```yaml
services:
  openvpn-as:
    image: linuxserver/openvpn-as:latest
    container_name: openvpn-as
    cap_add:
      - NET_ADMIN
    environment:
      - INTERFACE=eth0
    volumes:
      - ./openvpn-as:/config
    ports:
      - 943:943  # Admin UI
      - 9443:9443  # Web UI
      - 1194:1194/udp
    network_mode: host
    restart: unless-stopped
```

**優點**：
- 官方支援
- 完整功能
- NAT 自動處理

**缺點**：免費版只支援 2 個用戶

---

## 🎯 **方案 5：Tailscale + Headscale（自建）**

### Headscale (Tailscale 的開源版)
```yaml
services:
  headscale:
    image: headscale/headscale:latest
    container_name: headscale
    volumes:
      - ./headscale:/etc/headscale
    command: headscale serve
    network_mode: host
    restart: unless-stopped
```

**優點**：
- 現代化 WireGuard 架構
- 零配置 NAT 穿透
- 點對點連接
- 超簡單

**缺點**：
- 需要每個客戶端安裝 Tailscale
- 控制模式不同

---

## 📊 **總結對比**

| 方案 | 難度 | NAT 支援 | GUI | 企業功能 | 推薦度 |
|------|------|---------|-----|---------|--------|
| **Netmaker** | ⭐⭐⭐ | ✅ 原生 | ✅ 優秀 | ✅ 完整 | ⭐⭐⭐⭐⭐ |
| **Pritunl (host)** | ⭐ | ✅ 自動 | ✅ 有 | ✅ 好 | ⭐⭐⭐⭐ |
| **WireGuard** | ⭐⭐ | ✅ 自動 | ❌ 無 | ⚠️ 基本 | ⭐⭐⭐ |
| **OpenVPN-AS** | ⭐ | ✅ 自動 | ✅ 優秀 | ⚠️ 付費 | ⭐⭐⭐ |
| **Headscale** | ⭐⭐⭐ | ✅ 原生 | ⚠️ CLI | ✅ 好 | ⭐⭐⭐⭐ |

---

## 🎯 **我的建議**

### **短期（馬上可用）**：
→ **修改 Pritunl 為 `network_mode: host`**
   - 5 分鐘搞定
   - NAT 自動工作
   - 保留現有配置

### **長期（生產環境）**：
→ **改用 Netmaker**
   - 專為企業 Gateway 設計
   - 完整的 ACL、審計
   - 更好的擴展性

---

## ❓ **你要哪個方案？**

1. **快速修復**：改 Pritunl 為 host 模式（我馬上幫你改）
2. **重新開始**：安裝 Netmaker（15 分鐘）
3. **換成 WireGuard**：輕量但沒 GUI
4. **其他**：告訴我你的需求
