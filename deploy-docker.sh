#!/bin/bash

echo "======================================"
echo "  部署面試簡報（Docker 方式）"
echo "======================================"
echo ""

# 檢查 Docker 是否安裝
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安裝，請先安裝 Docker"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

# 檢查 docker-compose 是否安裝
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose 未安裝，請先安裝 docker-compose"
    exit 1
fi

echo "✅ Docker 環境檢查通過"
echo ""

# 停止舊容器
echo "停止舊容器..."
docker-compose down

# 構建並啟動
echo ""
echo "構建並啟動容器..."
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================"
    echo "✅ 部署成功！"
    echo "======================================"
    echo ""
    echo "📱 本地訪問："
    echo "   http://localhost:8080"
    echo ""
    echo "🔍 查看日誌："
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 停止服務："
    echo "   docker-compose down"
    echo ""
else
    echo ""
    echo "❌ 部署失敗"
    exit 1
fi

