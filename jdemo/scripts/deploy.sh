#!/bin/bash

# 伺服器端部署腳本
# 由 GitLab CI/CD 或手動執行

set -e

DEPLOY_DIR="/opt/jdemo"
LOG_FILE="$DEPLOY_DIR/deploy.log"

# 記錄函數
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "🚀 開始部署..."
log "================================"

# 切換到部署目錄
cd $DEPLOY_DIR

# 檢查 docker-compose.yml 是否存在
if [ ! -f "docker-compose.yml" ]; then
    log "❌ 錯誤: 找不到 docker-compose.yml"
    exit 1
fi

# 登入 GitLab Registry（如果有提供認證資訊）
if [ -n "$CI_REGISTRY_USER" ] && [ -n "$CI_REGISTRY_PASSWORD" ]; then
    log "🔐 登入 Container Registry..."
    echo $CI_REGISTRY_PASSWORD | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
fi

# 拉取最新映像檔
log "📥 拉取最新映像檔..."
docker-compose pull

# 停止舊容器（graceful shutdown）
if docker ps | grep -q jdemo-api; then
    log "🛑 停止舊容器..."
    docker-compose down --timeout 30
fi

# 啟動新容器
log "🚀 啟動新容器..."
docker-compose up -d

# 等待服務啟動
log "⏳ 等待服務啟動..."
MAX_WAIT=60
WAIT_TIME=0
while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8080/hello?name=healthcheck > /dev/null; then
        log "✅ 服務啟動成功！"
        break
    fi
    sleep 2
    WAIT_TIME=$((WAIT_TIME + 2))
done

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    log "⚠️ 服務啟動超時"
    log "查看日誌: docker logs jdemo-api"
    exit 1
fi

# 健康檢查
log "🧪 執行健康檢查..."
RESPONSE=$(curl -s http://localhost:8080/hello?name=deploy)
if [ -n "$RESPONSE" ]; then
    log "✅ 健康檢查通過"
    log "回應: $RESPONSE"
else
    log "❌ 健康檢查失敗"
    exit 1
fi

# 清理舊映像檔
log "🧹 清理舊映像檔..."
docker image prune -f

log "================================"
log "🎉 部署完成！"
log ""
log "📊 容器狀態:"
docker ps --filter name=jdemo-api

log ""
log "📝 查看日誌: docker logs -f jdemo-api"
