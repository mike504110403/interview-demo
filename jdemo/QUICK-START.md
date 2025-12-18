# 🚀 快速開始指南

## 本地測試（已完成 ✅）

### 方式 1: 直接執行 JAR
```bash
./gradlew bootRun
# 或
./gradlew build && java -jar build/libs/jdemo-0.0.1-SNAPSHOT.jar
```

### 方式 2: Docker 部署（推薦）
```bash
./deploy-docker-simple.sh
```

測試 API:
```bash
curl "http://localhost:8080/hello?name=World"
```

---

## GitLab CI/CD 部署（3 步驟）

### 📝 步驟 1: 更新 GitLab CI 配置

編輯 `.gitlab-ci.yml` 第 59 行，更新您的映像檔位址：

```yaml
DOCKER_IMAGE: "registry.gitlab.com/YOUR_USERNAME/YOUR_PROJECT"
```

### 🔐 步驟 2: 設定 GitLab 環境變數

前往: **Settings** → **CI/CD** → **Variables**

必須設定的變數：

| 變數名 | 值 | 說明 |
|--------|-----|------|
| `CI_REGISTRY_USER` | your-username | GitLab 使用者名稱 |
| `CI_REGISTRY_PASSWORD` | glpat-xxx | Personal Access Token |
| `SSH_PRIVATE_KEY` | -----BEGIN...END----- | SSH 私鑰 |
| `DEV_SERVER_HOST` | dev.example.com | 開發伺服器 |
| `DEV_SERVER_USER` | deployer | SSH 使用者 |
| `PROD_SERVER_HOST` | prod.example.com | 生產伺服器 |
| `PROD_SERVER_USER` | deployer | SSH 使用者 |

### 🖥️ 步驟 3: 準備伺服器

在伺服器上執行：

```bash
# 方式 1: 使用自動腳本（推薦）
curl -sSL https://your-gitlab.com/your-project/-/raw/main/scripts/server-setup.sh | bash

# 方式 2: 手動設定
# 1. 安裝 Docker
curl -fsSL https://get.docker.com | sudo sh

# 2. 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. 建立部署目錄
sudo mkdir -p /opt/jdemo
sudo chown $USER:$USER /opt/jdemo

# 4. 建立 docker-compose.yml
cd /opt/jdemo
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  jdemo-api:
    image: registry.gitlab.com/YOUR_USERNAME/YOUR_PROJECT:latest
    container_name: jdemo-api
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-Xmx512m -Xms256m
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/hello?name=health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# 5. 設定 SSH 公鑰
mkdir -p ~/.ssh
echo "your-public-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## 🎯 部署流程

### 自動部署（透過 GitLab CI/CD）

```bash
# 1. 推送程式碼
git add .
git commit -m "Update feature"
git push origin main

# 2. 前往 GitLab 查看 Pipeline
# https://gitlab.com/YOUR_USERNAME/YOUR_PROJECT/-/pipelines

# 3. 手動觸發部署
# 點擊 Pipeline 中的 deploy:prod 播放按鈕
```

### 手動部署（在伺服器上）

```bash
# SSH 到伺服器
ssh deployer@your-server.com

# 執行部署腳本
cd /opt/jdemo
./deploy.sh

# 或手動執行
docker-compose pull
docker-compose up -d

# 查看日誌
docker logs -f jdemo-api
```

---

## 📊 常用命令

### 本地開發

```bash
# 啟動開發伺服器
./gradlew bootRun

# 執行測試
./gradlew test

# 建置 JAR
./gradlew build

# Docker 部署
./deploy-docker-simple.sh

# 停止 Docker
./stop-docker.sh
```

### 生產環境

```bash
# 查看狀態
docker ps
docker stats jdemo-api

# 查看日誌
docker logs -f jdemo-api
docker logs --tail 100 jdemo-api

# 重啟服務
docker restart jdemo-api

# 更新服務
cd /opt/jdemo
docker-compose pull
docker-compose up -d

# 回滾版本
./scripts/rollback.sh main-abc123
```

### 測試 API

```bash
# GET 請求
curl "http://localhost:8080/hello?name=World"

# POST 請求
curl -X POST http://localhost:8080/hello \
  -H "Content-Type: application/json" \
  -d '{"name":"World","age":25}'

# 其他端點
curl http://localhost:8080/goodbye
curl http://localhost:8080/user
```

---

## 📁 專案結構

```
jdemo/
├── src/                          # 原始碼
├── build.gradle                  # Gradle 配置
├── .gitlab-ci.yml               # CI/CD 配置 ⭐
├── Dockerfile.simple            # Docker 映像檔 ⭐
├── docker-compose.yml           # 本地開發用
├── docker-compose.prod.yml      # 生產環境用 ⭐
├── scripts/
│   ├── server-setup.sh         # 伺服器初始化 ⭐
│   ├── deploy.sh               # 部署腳本 ⭐
│   └── rollback.sh             # 回滾腳本 ⭐
├── deploy-docker-simple.sh     # 本地 Docker 部署
├── stop-docker.sh              # 停止 Docker
├── QUICK-START.md              # 本文件
├── CICD-SETUP.md               # CI/CD 詳細指南 📚
└── README-DEPLOYMENT.md        # 部署總結 📚
```

⭐ = CI/CD 相關檔案  
📚 = 詳細文件

---

## 🆘 故障排除

### 問題 1: Pipeline 失敗

```bash
# 查看 Pipeline 日誌
# GitLab → CI/CD → Pipelines → 點擊失敗的階段

# 常見原因：
# - 環境變數未設定
# - Docker Registry 權限問題
# - SSH 連線失敗
```

### 問題 2: 容器無法啟動

```bash
# 查看容器日誌
docker logs jdemo-api

# 檢查容器狀態
docker ps -a
docker inspect jdemo-api

# 常見原因：
# - 端口被佔用
# - JAR 檔案損壞
# - JVM 記憶體不足
```

### 問題 3: API 無法訪問

```bash
# 檢查容器是否運行
docker ps | grep jdemo-api

# 檢查端口映射
docker port jdemo-api

# 檢查防火牆
sudo ufw status
sudo firewall-cmd --list-ports

# 測試容器內部
docker exec jdemo-api wget -O- http://localhost:8080/hello?name=test
```

---

## 📚 延伸閱讀

- **CICD-SETUP.md** - 完整的 CI/CD 設定指南
- **README-DEPLOYMENT.md** - 部署方式比較和總結
- **DOCKER-README.md** - Docker 詳細使用說明

---

## ✅ 檢查清單

部署前確認：

- [ ] GitLab 環境變數已設定
- [ ] 伺服器已安裝 Docker 和 Docker Compose
- [ ] SSH 金鑰已設定
- [ ] 防火牆已開放 8080 端口
- [ ] docker-compose.yml 已更新映像檔位址
- [ ] 本地測試通過

部署後確認：

- [ ] Pipeline 全部通過
- [ ] 容器正常運行
- [ ] API 可以訪問
- [ ] 健康檢查通過
- [ ] 日誌無錯誤

---

## 🎉 完成！

現在您已經有了完整的 CI/CD 流程：

**開發 → 推送 → 自動測試 → 自動建置 → 自動打包 → 手動部署 → 監控**

祝您部署順利！🚀
