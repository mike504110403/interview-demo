# VPN Server 專案

## 🎯 方案對比

### wg-easy - 簡單但功能有限

**優點：**
- ✅ 3 分鐘部署
- ✅ 介面簡潔漂亮
- ✅ 零學習成本

**缺點：**
- ❌ **沒有權限管理**
- ❌ **沒有角色控制**
- ❌ 無法設定路由策略
- ❌ 無法限制流量
- ❌ 沒有 SSO / MFA
- ❌ 審計功能陽春

**適合：**
- 小團隊（< 20 人）
- 簡單需求
- 快速測試

---

### Pritunl - 企業級完整功能

**優點：**
- ✅ **完整的權限管理系統**
- ✅ **多組織 / 多角色**
- ✅ SSO 整合（Google, Azure AD, Okta）
- ✅ MFA（雙因素認證）
- ✅ 細緻的路由控制
- ✅ 流量限制
- ✅ 連線時間限制
- ✅ 詳細審計日誌
- ✅ IP 池管理
- ✅ 群組管理

**缺點：**
- ⚠️ 部署較複雜（需要 MongoDB）
- ⚠️ 資源消耗較大
- ⚠️ 學習曲線陡峭

**適合：**
- 中大型團隊（> 20 人）
- 需要權限管理
- 企業合規要求

---

## 📊 功能對比表

| 功能 | wg-easy | Pritunl |
|------|---------|---------|
| **基本管理** | ✅ | ✅ |
| **QR Code** | ✅ | ✅ |
| **權限管理** | ❌ | ✅ |
| **角色/群組** | ❌ | ✅ |
| **SSO** | ❌ | ✅ |
| **MFA** | ❌ | ✅ |
| **路由策略** | 固定 | ✅ 靈活 |
| **流量限制** | ❌ | ✅ |
| **時間限制** | ❌ | ✅ |
| **審計日誌** | 基本 | ✅ 完整 |
| **多組織** | ❌ | ✅ |
| **IP 管理** | 自動 | ✅ 靈活 |

---

## 🚀 部署指南

### 目前已部署：wg-easy + DNS

```bash
cd docker/wg-easy-dns
docker-compose up -d

# 訪問：http://localhost:51821
# 密碼：Rd156156
```

### 如需升級到 Pritunl

```bash
# 停止 wg-easy
cd docker/wg-easy-dns
docker-compose down

# 啟動 Pritunl
cd ../pritunl
docker-compose up -d

# 等待 30 秒後訪問
open https://localhost:9700
```

---

## 💡 我的建議

### 情境 1: 如果您的需求是

**簡單的 VPN 連線 + 內部 DNS：**
```
→ 繼續使用 wg-easy ✅
→ 手動管理權限（透過開關 Client）
→ 透過分組命名管理（如 dev_*, admin_*）
```

### 情境 2: 如果您需要

**真正的權限管理系統：**
```
→ 升級到 Pritunl ✅
→ 設定組織和角色
→ 配置 SSO / MFA
→ 建立審計流程
```

---

## 📖 Pritunl 權限功能展示

### 1. 組織管理
```
可以建立多個組織：
- Engineering (工程部)
- Design (設計部)
- Management (管理層)

每個組織有獨立的：
- 用戶列表
- 服務器配置
- 權限設定
```

### 2. 用戶權限
```
可以設定每個用戶：
- 允許的 IP 範圍
- 允許的時間段
- 最大連線數
- 流量限制
- DNS 設定
- 路由規則
```

### 3. 服務器路由
```
可以針對不同用戶/組織設定：
- 10.0.1.0/24 → 只給工程師
- 10.0.2.0/24 → 只給設計師
- 10.0.5.0/24 → 只給管理層
```

### 4. 審計日誌
```
完整記錄：
- 誰在什麼時間連線
- 連線了多久
- 傳輸了多少流量
- 訪問了哪些資源
```

---

## 🎯 您現在的選擇

### A. 繼續用 wg-easy（權限簡化版）

**手動管理方式：**
1. 為不同角色建立不同命名的用戶：
   ```
   admin_mike
   engineer_john
   designer_mary
   ```

2. 在內部服務上做權限控制：
   ```
   GitLab: 在 GitLab 內部管理權限
   Grafana: 在 Grafana 內部管理權限
   ```

3. 透過開關控制存取：
   ```
   離職 → 直接停用該用戶
   ```

### B. 升級到 Pritunl（完整權限管理）

**一鍵切換：**
```bash
# 1. 停止 wg-easy
cd /Users/mike/Documents/self/interview-demo/vpn-server/docker/wg-easy-dns
docker-compose down

# 2. 啟動 Pritunl
cd ../pritunl
docker-compose up -d

# 3. 初始化設定
docker-compose exec pritunl pritunl setup-key
docker-compose exec pritunl pritunl default-password

# 4. 訪問 GUI
open https://localhost:9700
```

---

## 🤝 我的推薦

基於您問到權限管理，我建議：

**如果團隊 < 20 人：**
- 先用 wg-easy 
- 在各個內部服務做權限管理
- 等需求明確再升級

**如果團隊 > 20 人 或有明確的權限需求：**
- 直接用 Pritunl
- 一次到位建立完整的權限體系

---

需要我幫您部署 Pritunl 嗎？還是先用 wg-easy 然後手動管理？
