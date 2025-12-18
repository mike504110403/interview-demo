#!/bin/bash

# 停止 JAR 服務腳本
echo "🛑 停止服務..."

# 方法 1: 如果有儲存 PID
if [ -f "app.pid" ]; then
    PID=$(cat app.pid)
    kill $PID
    rm app.pid
    echo "✅ 服務已停止（PID: $PID）"
else
    # 方法 2: 根據 JAR 名稱查找並停止
    PID=$(ps aux | grep 'jdemo-0.0.1-SNAPSHOT.jar' | grep -v grep | awk '{print $2}')
    if [ -n "$PID" ]; then
        kill $PID
        echo "✅ 服務已停止（PID: $PID）"
    else
        echo "⚠️  找不到運行中的服務"
    fi
fi
