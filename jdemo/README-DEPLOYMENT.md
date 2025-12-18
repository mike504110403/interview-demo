# Java 微服務部署總結

## 🎯 部署方式比較

我們實現了兩種部署方式，您已經成功完成了 **Docker 部署**！

### 1️⃣ JAR 部署（傳統方式）

```bash
# 建置
./gradlew clean build

# 運行
java -jar build/libs/jdemo-0.0.1-SNAPSHOT.jar

# 使用腳本
./deploy-jar.sh      # 啟動
./stop-jar.sh        # 停止
```

**優點**: 簡單、快速、資源少  
**缺點**: 環境依賴、難擴展

---

### 2️⃣ Docker 部署（現代方式）✅ 已完成

```bash
# 本地部署
./deploy-docker-simple.sh

# 使用 docker-compose
docker-compose up -d
```

**優點**: 環境一致、易擴展、適合 CI/CD  
**缺點**: 檔案較大、需學習 Docker

---

## 🚀 CI/CD 部署流程（已配置）

### 檔案清單

✅ **`.gitlab-ci.yml`** - GitLab CI/CD 配置
- 自動測試
- 自動建置 JAR
- 自動打包 Docker 映像檔
- 部署到開發/生產環境

✅ **`Dockerfile.simple`** - Docker 映像檔定義
- 使用 Java 17 JRE
- 輕量化設計
- 安全性最佳實踐

✅ **`docker-compose.yml`** - 本地開發用
✅ **`docker-compose.prod.yml`** - 生產環境用

✅ **`CICD-SETUP.md`** - 完整的 CI/CD 設定指南

✅ **`scripts/`** - 部署輔助腳本
- `server-setup.sh` - 伺服器初始化
- `deploy.sh` - 部署腳本
- `rollback.sh` - 回滾腳本

---

## 📋 完整 CI/CD 流程圖

```
本地開發
  │
  ├─ git push
  │
  ↓
GitLab CI/CD
  │
  ├─ 階段 1: 測試 (test)
  │   └─ 執行單元測試
  │
  ├─ 階段 2: 建置 (build)
  │   └─ 建置 JAR 檔案
  │
  ├─ 階段 3: Docker (docker)
  │   ├─ 建置 Docker 映像檔
  │   └─ 推送到 Registry
  │
  └─ 階段 4: 部署 (deploy)
      ├─ 開發環境 (手動觸發)
      └─ 生產環境 (手動觸發)
          │
          ↓
      部署伺服器
          ├─ 拉取最新映像檔
          ├─ 停止舊容器
          ├─ 啟動新容器
          └─ 健康檢查
```

---

## 🔧 下一步：設定 GitLab CI/CD

### 步驟 1: 上傳程式碼到 GitLab

```bash
# 如果還沒有 GitLab 專案，先創建一個
git remote add gitlab https://gitlab.com/your-username/jdemo.git
git push gitlab main
```

### 步驟 2: 設定 GitLab 環境變數

前往 GitLab 專案 → **Settings** → **CI/CD** → **Variables**

必要變數：
- `CI_REGISTRY_USER` - 您的 GitLab 使用者名稱
- `CI_REGISTRY_PASSWORD` - GitLab Personal Access Token
- `SSH_PRIVATE_KEY` - SSH 私鑰（用於連線到伺服器）
- `DEV_SERVER_HOST` - 開發伺服器位址
- `DEV_SERVER_USER` - SSH 登入使用者
- `PROD_SERVER_HOST` - 生產伺服器位址
- `PROD_SERVER_USER` - SSH 登入使用者

### 步驟 3: 準備部署伺服器

在伺服器上執行：

```bash
# 下載設定腳本
wget https://raw.githubusercontent.com/your-repo/jdemo/main/scripts/server-setup.sh

# 執行設定
chmod +x server-setup.sh
./server-setup.sh
```

或手動執行：

```bash
# 1. 安裝 Docker
curl -fsSL https://get.docker.com | sh

# 2. 建立部署目錄
sudo mkdir -p /opt/jdemo
sudo chown $USER:$USER /opt/jdemo

# 3. 設定 SSH 公鑰
# 將 GitLab CI 的 SSH 公鑰加入 ~/.ssh/authorized_keys
```

### 步驟 4: 測試 Pipeline

```bash
# 推送程式碼觸發 Pipeline
git add .
git commit -m "設定 CI/CD"
git push gitlab main

# 前往 GitLab 查看 Pipeline 狀態
# https://gitlab.com/your-username/jdemo/-/pipelines
```

### 步驟 5: 部署到生產環境

1. 前往 GitLab → CI/CD → Pipelines
2. 找到成功的 Pipeline
3. 點擊 `deploy:prod` 階段的播放按鈕
4. 等待部署完成

---

## 🧪 本地測試部署

### 測試 Docker 部署（已完成）✅

```bash
cd /Users/mike/Documents/self/interview-demo/jdemo

# 執行部署
./deploy-docker-simple.sh

# 測試 API
curl "http://localhost:8080/hello?name=Docker"

# 查看日誌
docker logs -f jdemo-api

# 停止服務
./stop-docker.sh
```

### 模擬 CI/CD 流程

```bash
# 1. 測試
./gradlew test

# 2. 建置
./gradlew clean build

# 3. 打包 Docker
docker build -f Dockerfile.simple -t jdemo-api:test .

# 4. 運行
docker run -d -p 8080:8080 --name jdemo-api-test jdemo-api:test

# 5. 測試
curl http://localhost:8080/hello?name=test

# 6. 清理
docker stop jdemo-api-test
docker rm jdemo-api-test
```

---

## 📊 監控和維護

### 常用命令

```bash
# 查看容器狀態
docker ps

# 查看資源使用
docker stats jdemo-api

# 查看日誌
docker logs -f jdemo-api
docker logs --tail 100 jdemo-api

# 重啟服務
docker restart jdemo-api

# 進入容器
docker exec -it jdemo-api sh

# 更新服務
cd /opt/jdemo
docker-compose pull
docker-compose up -d

# 回滾
./scripts/rollback.sh main-abc123
```

### 健康檢查

```bash
# 手動健康檢查
curl http://localhost:8080/hello?name=health

# Docker 健康檢查狀態
docker inspect jdemo-api | grep -A 10 Health
```

---

## 🎓 學習總結

### 您已經掌握：

✅ Java Spring Boot 開發  
✅ Gradle 專案建置  
✅ Docker 容器化  
✅ Docker Compose 編排  
✅ GitLab CI/CD 配置  
✅ 自動化部署流程  

### 進階主題（可選）：

- [ ] Kubernetes 部署
- [ ] 日誌收集（ELK Stack）
- [ ] 監控系統（Prometheus + Grafana）
- [ ] 服務網格（Istio）
- [ ] 資料庫整合
- [ ] Redis 快取
- [ ] API Gateway

---

## 📚 相關文件

- **`DOCKER-README.md`** - Docker 部署詳細說明
- **`CICD-SETUP.md`** - CI/CD 完整設定指南
- **`deploy-jar.sh`** - JAR 部署腳本
- **`deploy-docker-simple.sh`** - Docker 部署腳本
- **`.gitlab-ci.yml`** - CI/CD 配置檔案

---

## 💡 常見問題

### Q: 如何選擇 JAR 還是 Docker？

**開發/測試環境**: JAR（快速、簡單）  
**生產環境**: Docker（穩定、可擴展）  
**微服務架構**: Docker（必選）  

### Q: CI/CD 是必須的嗎？

不是必須，但強烈建議：
- 減少人為錯誤
- 加快部署速度
- 提高團隊協作效率
- 確保部署一致性

### Q: 如何處理資料庫？

可以在 `docker-compose.yml` 中加入資料庫服務：

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: jdemo
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
    volumes:
      - postgres-data:/var/lib/postgresql/data
```

---

## 🎉 恭喜！

您已經成功完成了從開發到部署的完整流程配置！

下一步可以：
1. 將程式碼推送到 GitLab
2. 設定 CI/CD 環境變數
3. 準備部署伺服器
4. 執行第一次自動化部署

祝部署順利！🚀
