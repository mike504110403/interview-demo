#!/bin/bash

# Docker 部署腳本 for Java 微服務
set -e

echo "🐳 Docker 部署開始..."
echo "================================"

# 檢查 Docker 是否安裝
if ! command -v docker &> /dev/null; then
    echo "❌ 錯誤: Docker 未安裝，請先安裝 Docker"
    exit 1
fi

# 檢查 Docker 是否運行
if ! docker info &> /dev/null; then
    echo "❌ 錯誤: Docker 未運行，請先啟動 Docker"
    exit 1
fi

# 設定變數
IMAGE_NAME="jdemo-api"
IMAGE_TAG="latest"
CONTAINER_NAME="jdemo-api"
PORT="8080"

echo "📋 配置資訊："
echo "  映像檔名稱: $IMAGE_NAME:$IMAGE_TAG"
echo "  容器名稱: $CONTAINER_NAME"
echo "  端口映射: $PORT:8080"
echo ""

# 停止並移除舊容器（如果存在）
echo "🧹 清理舊容器..."
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "  停止容器: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    echo "  移除容器: $CONTAINER_NAME"
    docker rm $CONTAINER_NAME 2>/dev/null || true
fi

# 建置 Docker 映像檔
echo ""
echo "🔨 建置 Docker 映像檔..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

if [ $? -eq 0 ]; then
    echo "✅ 映像檔建置成功！"
else
    echo "❌ 映像檔建置失敗！"
    exit 1
fi

# 啟動容器
echo ""
echo "🚀 啟動容器..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8080 \
    --restart unless-stopped \
    $IMAGE_NAME:$IMAGE_TAG

if [ $? -eq 0 ]; then
    echo "✅ 容器啟動成功！"
    echo ""
    echo "================================"
    echo "🎉 部署完成！"
    echo ""
    echo "📍 服務資訊："
    echo "  - API 端點: http://localhost:$PORT"
    echo "  - 測試 URL: http://localhost:$PORT/hello?name=Docker"
    echo ""
    echo "🔧 常用命令："
    echo "  - 查看日誌: docker logs $CONTAINER_NAME"
    echo "  - 即時日誌: docker logs -f $CONTAINER_NAME"
    echo "  - 停止服務: docker stop $CONTAINER_NAME"
    echo "  - 重啟服務: docker restart $CONTAINER_NAME"
    echo "  - 進入容器: docker exec -it $CONTAINER_NAME sh"
    echo ""
    
    # 等待服務啟動
    echo "⏳ 等待服務啟動..."
    sleep 5
    
    # 健康檢查
    if curl -s "http://localhost:$PORT/hello?name=Docker" > /dev/null; then
        echo "✅ 服務健康檢查通過！"
    else
        echo "⚠️  服務可能還在啟動中，請稍後再試"
    fi
else
    echo "❌ 容器啟動失敗！"
    exit 1
fi
