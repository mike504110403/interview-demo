# CI/CD 部署指南

本專案使用 **GitLab CI/CD** 進行自動化建置、測試和部署。

## 📋 目錄

1. [GitLab CI/CD 流程說明](#gitlab-cicd-流程說明)
2. [環境變數設定](#環境變數設定)
3. [伺服器準備](#伺服器準備)
4. [部署流程](#部署流程)
5. [常見問題](#常見問題)

---

## 🔄 GitLab CI/CD 流程說明

### Pipeline 階段

```
test → build → docker → deploy
```

#### 1️⃣ **Test 階段**
- 執行單元測試
- 生成測試報告
- **觸發時機**: 所有分支的 push 和 merge request

#### 2️⃣ **Build 階段**
- 使用 Gradle 建置 JAR 檔案
- 儲存為 artifact（有效期 1 天）
- **觸發時機**: 所有分支的 push

#### 3️⃣ **Docker 階段**
- 建置 Docker 映像檔
- 推送到 GitLab Container Registry
- 標記為 `latest` 和 `{branch}-{commit}`
- **觸發時機**: main/master/develop 分支和 tags

#### 4️⃣ **Deploy 階段**
- **開發環境**: develop 分支（手動觸發）
- **生產環境**: main/master 分支和 tags（手動觸發）

---

## 🔐 環境變數設定

在 GitLab 專案中設定以下環境變數：

### 前往：Settings → CI/CD → Variables

#### 必要變數

| 變數名稱 | 說明 | 是否保護 | 是否遮罩 |
|---------|------|---------|---------|
| `CI_REGISTRY_USER` | GitLab Registry 使用者名稱 | ✅ | ❌ |
| `CI_REGISTRY_PASSWORD` | GitLab Registry 密碼或 Token | ✅ | ✅ |
| `SSH_PRIVATE_KEY` | SSH 私鑰（用於連線到伺服器） | ✅ | ✅ |

#### 開發環境變數

| 變數名稱 | 說明 | 範例值 |
|---------|------|--------|
| `DEV_SERVER_HOST` | 開發伺服器 IP 或域名 | `dev.example.com` |
| `DEV_SERVER_USER` | SSH 登入使用者 | `deployer` |

#### 生產環境變數

| 變數名稱 | 說明 | 範例值 |
|---------|------|--------|
| `PROD_SERVER_HOST` | 生產伺服器 IP 或域名 | `prod.example.com` |
| `PROD_SERVER_USER` | SSH 登入使用者 | `deployer` |

### 如何設定 SSH_PRIVATE_KEY

```bash
# 1. 在本地生成 SSH 金鑰對（如果還沒有）
ssh-keygen -t ed25519 -C "gitlab-ci" -f ~/.ssh/gitlab_ci

# 2. 複製私鑰內容
cat ~/.ssh/gitlab_ci

# 3. 將私鑰內容貼到 GitLab Variables 的 SSH_PRIVATE_KEY

# 4. 將公鑰加到伺服器
ssh-copy-id -i ~/.ssh/gitlab_ci.pub deployer@your-server.com
```

---

## 🖥️ 伺服器準備

### 1. 安裝 Docker 和 Docker Compose

```bash
# 安裝 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 將使用者加入 docker 群組
sudo usermod -aG docker $USER

# 重新登入或執行
newgrp docker
```

### 2. 建立部署目錄

```bash
# 建立專案目錄
sudo mkdir -p /opt/jdemo
sudo chown $USER:$USER /opt/jdemo
cd /opt/jdemo

# 建立 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  jdemo-api:
    image: registry.gitlab.com/your-username/your-project:latest
    container_name: jdemo-api
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-Xmx512m -Xms256m
      - TZ=Asia/Taipei
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/hello?name=health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF
```

### 3. 設定防火牆（如果需要）

```bash
# Ubuntu/Debian
sudo ufw allow 8080/tcp
sudo ufw reload

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### 4. 登入 GitLab Container Registry

```bash
# 使用 GitLab Personal Access Token
docker login registry.gitlab.com -u your-username -p your-token
```

---

## 🚀 部署流程

### 方式 1: 透過 GitLab CI/CD（推薦）

#### 部署到開發環境

1. 推送程式碼到 `develop` 分支
2. 前往 GitLab → CI/CD → Pipelines
3. 找到最新的 Pipeline
4. 點擊 `deploy:dev` 階段的 ▶️ 播放按鈕
5. 等待部署完成

#### 部署到生產環境

1. 推送程式碼到 `main` 或 `master` 分支
2. 前往 GitLab → CI/CD → Pipelines
3. 找到最新的 Pipeline
4. 點擊 `deploy:prod` 階段的 ▶️ 播放按鈕
5. 等待部署完成並通過健康檢查

### 方式 2: 手動部署到伺服器

```bash
# 1. SSH 連線到伺服器
ssh deployer@your-server.com

# 2. 進入專案目錄
cd /opt/jdemo

# 3. 拉取最新映像檔
docker-compose pull

# 4. 重啟服務
docker-compose up -d

# 5. 查看日誌
docker-compose logs -f

# 6. 測試服務
curl http://localhost:8080/hello?name=test
```

---

## 📊 監控和維護

### 查看容器狀態

```bash
docker ps
docker stats jdemo-api
```

### 查看日誌

```bash
# 即時日誌
docker logs -f jdemo-api

# 最近 100 行
docker logs --tail 100 jdemo-api

# 使用 docker-compose
docker-compose logs -f
```

### 重啟服務

```bash
# 使用 Docker
docker restart jdemo-api

# 使用 docker-compose
docker-compose restart
```

### 更新服務

```bash
cd /opt/jdemo
docker-compose pull
docker-compose up -d
```

### 清理舊映像檔

```bash
# 移除未使用的映像檔
docker image prune -a

# 清理所有未使用資源
docker system prune -a
```

---

## 🧪 測試 API

```bash
# 健康檢查
curl http://localhost:8080/hello?name=health

# GET 請求
curl "http://localhost:8080/hello?name=Docker"

# POST 請求
curl -X POST http://localhost:8080/hello \
  -H "Content-Type: application/json" \
  -d '{"name":"Docker","age":25}'

# 其他端點
curl http://localhost:8080/goodbye
curl http://localhost:8080/user
```

---

## ❓ 常見問題

### Q1: Pipeline 在 Docker 階段失敗，提示無法連接到 Docker daemon

**A**: 確保 `.gitlab-ci.yml` 中有設定 `docker:dind` service，並檢查 GitLab Runner 是否支援 Docker。

### Q2: 部署階段無法 SSH 連線到伺服器

**A**: 檢查：
1. `SSH_PRIVATE_KEY` 環境變數是否正確設定
2. 伺服器的 SSH 公鑰是否已加入授權清單
3. 防火牆是否允許 SSH（port 22）

### Q3: Docker 映像檔無法推送到 Registry

**A**: 確認：
1. `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 是否正確
2. GitLab Container Registry 是否已啟用
3. 專案權限設定是否正確

### Q4: 服務無法啟動，健康檢查失敗

**A**: 執行以下命令診斷：
```bash
docker logs jdemo-api
docker inspect jdemo-api
```

### Q5: 如何回滾到上一個版本？

```bash
# 方法 1: 使用特定標籤
cd /opt/jdemo
# 修改 docker-compose.yml 中的 image 標籤
docker-compose up -d

# 方法 2: 手動指定映像檔
docker stop jdemo-api
docker rm jdemo-api
docker run -d --name jdemo-api -p 8080:8080 \
  registry.gitlab.com/your-project:develop-abc123
```

---

## 📚 相關檔案

- `.gitlab-ci.yml` - CI/CD 配置檔
- `Dockerfile.simple` - Docker 映像檔定義
- `docker-compose.yml` - 本地開發用
- `docker-compose.prod.yml` - 生產環境用

---

## 🔗 參考資源

- [GitLab CI/CD 文件](https://docs.gitlab.com/ee/ci/)
- [Docker 官方文件](https://docs.docker.com/)
- [Spring Boot Docker 最佳實踐](https://spring.io/guides/topicals/spring-boot-docker)
