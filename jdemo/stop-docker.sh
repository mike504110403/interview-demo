#!/bin/bash

# 停止 Docker 容器腳本
echo "🛑 停止 Docker 容器..."

CONTAINER_NAME="jdemo-api"

# 檢查容器是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "📦 找到容器: $CONTAINER_NAME"
    
    # 停止容器
    docker stop $CONTAINER_NAME
    echo "✅ 容器已停止"
    
    # 移除容器
    docker rm $CONTAINER_NAME
    echo "✅ 容器已移除"
else
    echo "⚠️  找不到運行中的容器: $CONTAINER_NAME"
fi

echo ""
echo "💡 其他常用命令："
echo "  - 查看所有容器: docker ps -a"
echo "  - 移除映像檔: docker rmi jdemo-api:latest"
echo "  - 清理未使用資源: docker system prune"
