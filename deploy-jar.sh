#!/bin/bash

# JAR 部署腳本
echo "🚀 開始部署 JAR..."

# 1. 建置專案
echo "📦 建置中..."
cd jdemo
./gradlew clean build

# 2. 檢查建置結果
if [ $? -eq 0 ]; then
    echo "✅ 建置成功！"
else
    echo "❌ 建置失敗！"
    exit 1
fi

# 3. 啟動服務
echo "🎯 啟動服務..."
JAR_FILE="build/libs/jdemo-0.0.1-SNAPSHOT.jar"

# 檢查 Java 版本
java -version

# 啟動應用（前台運行）
java -jar $JAR_FILE

# 如果要背景運行，使用：
# nohup java -jar $JAR_FILE > app.log 2>&1 &
# echo "PID: $!" > app.pid
