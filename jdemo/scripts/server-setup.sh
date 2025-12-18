#!/bin/bash

# 伺服器初始設定腳本
# 用於準備部署環境

set -e

echo "🚀 開始設定伺服器環境..."
echo "================================"

# 檢查是否為 root 或有 sudo 權限
if [ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null; then 
    echo "❌ 需要 sudo 權限，請使用 sudo 執行此腳本"
    exit 1
fi

# ==========================================
# 1. 系統更新
# ==========================================
echo ""
echo "📦 步驟 1: 更新系統套件..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y curl wget git
elif command -v yum &> /dev/null; then
    sudo yum update -y
    sudo yum install -y curl wget git
else
    echo "⚠️  無法識別的套件管理器"
fi

# ==========================================
# 2. 安裝 Docker
# ==========================================
echo ""
echo "🐳 步驟 2: 安裝 Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安裝: $(docker --version)"
else
    echo "安裝 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "✅ Docker 安裝完成"
fi

# ==========================================
# 3. 安裝 Docker Compose
# ==========================================
echo ""
echo "🔧 步驟 3: 安裝 Docker Compose..."
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose 已安裝: $(docker-compose --version)"
else
    echo "安裝 Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose 安裝完成"
fi

# ==========================================
# 4. 設定 Docker 使用者權限
# ==========================================
echo ""
echo "👤 步驟 4: 設定 Docker 使用者權限..."
if groups $USER | grep -q '\bdocker\b'; then
    echo "✅ 使用者 $USER 已在 docker 群組中"
else
    sudo usermod -aG docker $USER
    echo "✅ 已將 $USER 加入 docker 群組"
    echo "⚠️  請登出後重新登入，或執行: newgrp docker"
fi

# ==========================================
# 5. 建立部署目錄
# ==========================================
echo ""
echo "📁 步驟 5: 建立部署目錄..."
DEPLOY_DIR="/opt/jdemo"
if [ -d "$DEPLOY_DIR" ]; then
    echo "✅ 目錄已存在: $DEPLOY_DIR"
else
    sudo mkdir -p $DEPLOY_DIR
    sudo chown $USER:$USER $DEPLOY_DIR
    echo "✅ 已建立目錄: $DEPLOY_DIR"
fi

# ==========================================
# 6. 建立 docker-compose.yml
# ==========================================
echo ""
echo "📝 步驟 6: 建立 docker-compose.yml..."
cat > $DEPLOY_DIR/docker-compose.yml << 'EOF'
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
echo "✅ docker-compose.yml 已建立"
echo "⚠️  請編輯 $DEPLOY_DIR/docker-compose.yml 並更新映像檔位址"

# ==========================================
# 7. 設定防火牆（如果有）
# ==========================================
echo ""
echo "🔥 步驟 7: 設定防火牆..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 8080/tcp
    echo "✅ 已開放 8080 端口 (ufw)"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
    echo "✅ 已開放 8080 端口 (firewalld)"
else
    echo "⚠️  未偵測到防火牆管理工具"
fi

# ==========================================
# 8. 測試 Docker
# ==========================================
echo ""
echo "🧪 步驟 8: 測試 Docker..."
if docker run --rm hello-world > /dev/null 2>&1; then
    echo "✅ Docker 運行正常"
else
    echo "⚠️  Docker 測試失敗，可能需要重新登入"
fi

# ==========================================
# 完成
# ==========================================
echo ""
echo "================================"
echo "✅ 伺服器設定完成！"
echo ""
echo "📋 下一步："
echo "  1. 登出後重新登入（使 docker 群組生效）"
echo "  2. 編輯 $DEPLOY_DIR/docker-compose.yml 更新映像檔位址"
echo "  3. 設定 GitLab CI/CD 環境變數"
echo "  4. 執行部署測試"
echo ""
echo "🔗 詳細說明請參考: CICD-SETUP.md"
