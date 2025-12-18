#!/bin/bash

# 回滾腳本
# 用於快速回滾到上一個版本

set -e

DEPLOY_DIR="/opt/jdemo"

echo "🔄 回滾服務..."
echo "================================"

if [ -z "$1" ]; then
    echo "❌ 錯誤: 請提供要回滾到的映像檔標籤"
    echo ""
    echo "用法: $0 <image-tag>"
    echo "範例: $0 main-abc123"
    echo ""
    echo "可用的映像檔標籤:"
    docker images | grep jdemo
    exit 1
fi

IMAGE_TAG=$1
IMAGE_NAME="registry.gitlab.com/YOUR_USERNAME/YOUR_PROJECT:$IMAGE_TAG"

echo "📋 回滾資訊:"
echo "  目標映像檔: $IMAGE_NAME"
echo ""

# 確認
read -p "確定要回滾嗎？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 1
fi

cd $DEPLOY_DIR

# 停止目前容器
echo "🛑 停止目前容器..."
docker-compose down

# 更新映像檔
echo "🔄 切換映像檔..."
sed -i "s|image:.*|image: $IMAGE_NAME|g" docker-compose.yml

# 啟動容器
echo "🚀 啟動容器..."
docker-compose up -d

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 10

# 健康檢查
if curl -s http://localhost:8080/hello?name=rollback > /dev/null; then
    echo "✅ 回滾成功！"
    echo ""
    echo "當前版本:"
    docker ps --filter name=jdemo-api
else
    echo "❌ 回滾失敗，請檢查日誌"
    docker logs jdemo-api
    exit 1
fi
