#!/bin/bash

echo "========================================"
echo "專案建置經驗分享 - 簡報系統"
echo "========================================"
echo ""
echo "選擇啟動方式："
echo "1. 直接開啟簡報 (index.html)"
echo "2. 啟動本地伺服器"
echo ""
read -p "請輸入選項 (1-2): " choice

case $choice in
    1)
        echo ""
        echo "開啟簡報..."
        echo "提示：使用上方Tab切換「主簡報」和「直播技術」"
        open index.html
        ;;
    2)
        echo ""
        echo "啟動本地伺服器..."
        echo "伺服器地址：http://localhost:8000/"
        echo ""
        echo "提示：使用上方Tab切換「主簡報」和「直播技術」"
        echo "按 Ctrl+C 停止伺服器"
        echo ""
        python3 -m http.server 8000
        ;;
    *)
        echo "無效的選項"
        ;;
esac
