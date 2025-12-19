# 🚀 快速開始指南

## 👋 歡迎

這是一份精簡的快速開始指南，幫助您快速理解整體架構並開始實施。

---

## 🎯 核心概念（5分鐘理解）

### 單一入口設計

```
外部世界
    ↓
VPN Gateway (唯一入口)
    ↓
內部服務（全部受保護）
    ├── GitLab
    ├── Dev Environment
    ├── Staging
    └── Monitoring

關鍵: 所有服務只對 VPN Gateway 開放白名單！
```

### 為什麼這樣設計？

**問題**：
- ❌ 如果每個服務都對外開放 → 攻擊面大
- ❌ 如果每個服務都有自己的認證 → 難管理
- ❌ 如果沒有統一記錄 → 無法追蹤「誰做了什麼」

**解決方案**：
- ✅ VPN Gateway 統一認證
- ✅ 所有流量都經過 Gateway → 完整記錄
- ✅ 撤銷權限 = 移除 VPN 存取 → 立即生效

---

## 📋 3步驟快速實施

### 步驟 1: 設置 VPN Gateway（第1週）

**做什麼**：
1. 租用一台伺服器（公網 IP）
2. 安裝 WireGuard
3. 為每位員工生成 VPN 配置
4. 員工連接 VPN 進入內網

**檢驗**：
```bash
# 員工連上 VPN 後可以 ping 通內網
ping 10.0.1.10  # GitLab Server
```

### 步驟 2: 部署內部服務（第2-3週）

**做什麼**：
1. 租用 3-5 台伺服器（私有 IP）
2. 在防火牆設定只允許 VPN Gateway 存取
3. 部署 GitLab、Dev、Staging 環境
4. 測試員工可透過 VPN 存取

**檢驗**：
```bash
# 員工透過 VPN 存取 GitLab
https://gitlab.company.internal  # ✅ 可以訪問

# 直接從外網存取
https://gitlab-server-ip  # ❌ 被防火牆阻擋
```

### 步驟 3: 建立監控（第4週）

**做什麼**：
1. 部署 ELK Stack 收集日誌
2. 設定 Grafana 儀表板
3. 配置告警規則
4. 測試告警是否正常

**檢驗**：
```bash
# 查看儀表板可以看到
- 誰連線了
- 存取了哪些服務
- 何時進行的操作
```

---

## 📊 關鍵決策樹

### 我應該用幾台伺服器？

```
團隊 < 10人
└── 3台即可
    ├── Server 1: VPN Gateway + GitLab
    ├── Server 2: Dev + Staging
    └── Server 3: Monitoring
    💰 成本: $200-300/月

團隊 10-30人
└── 5台建議
    ├── Server 1: VPN Gateway
    ├── Server 2: GitLab
    ├── Server 3: Dev Environment
    ├── Server 4: Staging Environment
    └── Server 5: Monitoring + DB
    💰 成本: $400-500/月

團隊 30-50人
└── 8-10台
    ├── 專用 VPN Gateway (可能2台高可用)
    ├── 專用 GitLab 叢集
    ├── 獨立的各環境
    └── 專用監控叢集
    💰 成本: $800-1200/月
```

### 我需要付費軟體嗎？

```
必須付費
└── 無！全部可用開源方案
    ├── WireGuard (VPN) - 免費
    ├── GitLab CE - 免費
    ├── ELK Stack - 免費
    └── Prometheus + Grafana - 免費

可選付費（更好體驗）
└── 看需求選擇
    ├── GitLab EE - $200/月 (進階功能)
    ├── Cloudflare - $20/月 (CDN + 安全)
    └── 異地備份 - $50/月
```

### VPN 一定要用 WireGuard 嗎？

```
推薦 WireGuard
✅ 現代化、快速、安全
✅ 配置簡單
✅ 跨平台支援好

替代方案
├── OpenVPN - 傳統、功能多、配置複雜
├── IPsec - 企業級、複雜、相容性好
└── Tailscale - 商業化 WireGuard、易用

建議: 起步用 WireGuard
```

---

## ⚡ 30分鐘體驗（本機測試）

想快速體驗這套架構？用 Docker Compose 在本機試試：

### 1. 建立測試環境

```bash
# 創建 docker-compose.yml
cat > docker-compose-test.yml << 'EOF'
version: '3.8'

services:
  # 模擬 VPN Gateway (簡化版)
  gateway:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./gateway-logs:/var/log/nginx
    networks:
      internal:
        ipv4_address: 10.0.0.1

  # 模擬 GitLab
  gitlab:
    image: nginx:alpine
    networks:
      internal:
        ipv4_address: 10.0.1.10

  # 模擬監控
  monitoring:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    networks:
      internal:
        ipv4_address: 10.0.5.10

networks:
  internal:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/16
EOF

# 啟動
docker-compose -f docker-compose-test.yml up -d

# 測試
curl http://localhost:8080  # Gateway
curl http://localhost:3000  # Monitoring
```

### 2. 觀察流量

```bash
# 查看 Gateway 日誌（模擬記錄）
tail -f gateway-logs/access.log

# 你會看到所有請求都經過 Gateway
```

### 3. 清理

```bash
docker-compose -f docker-compose-test.yml down
```

---

## 📚 下一步該讀什麼？

### 如果您是...

**CTO / 決策者**
→ 先讀 `README.md` 了解全貌
→ 再讀 `01-整體架構設計.md` 理解設計理念
→ 最後看預算和時程規劃

**Tech Lead / 實施者**
→ 先讀 `02-網路拓撲圖.md` 了解網路規劃
→ 再讀 `03-安全策略.md` 理解安全要求
→ 開始按照實施計畫執行

**DevOps / 運維**
→ 直接看 `configs/` 資料夾的配置範本
→ 參考 `scripts/` 的自動化腳本
→ 閱讀 `04-監控方案.md` 設置監控

**一般工程師**
→ 了解如何連接 VPN
→ 理解公司的安全政策
→ 知道如何存取內部服務

---

## 🎓 常見問題

### Q1: 這套架構複雜嗎？

**A**: 核心概念很簡單：
```
員工 → VPN → 內部服務
所有東西只對 VPN 開放
```

複雜的是「細節」，但我們已經為您準備好完整文檔。

### Q2: 需要多少時間建置？

**A**: 
- 基礎版本: 1週（VPN + 基本服務）
- 完整版本: 1個月（包含監控、告警）
- 成熟穩定: 3個月（優化、完善）

### Q3: 如果 VPN Gateway 壞了怎麼辦？

**A**: 
- 短期: 準備備用 VPN Gateway 配置（冷備份）
- 長期: 建立高可用架構（2台 Gateway）
- 現實: 選擇可靠的雲端服務商，故障機率很低

### Q4: 會不會影響效能？

**A**:
- VPN 延遲: 通常 < 50ms（可接受）
- 額外負載: Gateway CPU 使用 < 30%
- 實際體驗: 幾乎無感

### Q5: 成本會不會很高？

**A**:
- 小團隊: $200-300/月（比傳統方案便宜）
- 中團隊: $400-500/月（合理）
- 相比安全事件損失: 非常划算

---

## ✅ 檢查清單

開始前確認：

### 管理決策
- [ ] 獲得預算批准（$300-500/月）
- [ ] 確認團隊規模（決定伺服器數量）
- [ ] 設定實施時程（1-3個月）

### 技術準備
- [ ] 選擇雲端服務商（AWS/GCP/Azure/DigitalOcean）
- [ ] 註冊域名（company.com）
- [ ] 準備 SSL 憑證（可用 Let's Encrypt）

### 團隊準備
- [ ] 指派負責人（Tech Lead）
- [ ] 安排實施工程師
- [ ] 規劃培訓時間

---

## 🚀 馬上開始

```bash
# 第1步: 閱讀完整架構
open README.md

# 第2步: 了解網路規劃
open 02-網路拓撲圖.md

# 第3步: 學習安全策略
open 03-安全策略.md

# 第4步: 開始實施！
# （參考各文檔中的實施步驟）
```

---

祝您建置順利！有任何問題歡迎隨時討論。🎉
