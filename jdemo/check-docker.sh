#!/bin/bash

echo "🔍 檢查 Docker 狀態..."
echo ""

# 檢查 Docker 版本
echo "📋 Docker 版本："
docker --version

echo ""

# 檢查 Docker 是否運行
echo "🐳 Docker 服務狀態："
if docker info &> /dev/null; then
    echo "✅ Docker 正在運行"
    echo ""
    docker info | grep "Server Version"
    docker info | grep "Operating System"
    docker info | grep "Total Memory"
    echo ""
    echo "✅ 您可以開始部署了！"
    echo "執行: ./deploy-docker.sh"
else
    echo "❌ Docker 未運行"
    echo ""
    echo "請啟動 Docker Desktop："
    echo "  方法 1: 從應用程式中打開 Docker"
    echo "  方法 2: 執行 'open -a Docker'"
    echo ""
    echo "啟動後等待約 10-30 秒，再次執行此腳本檢查"
fi
