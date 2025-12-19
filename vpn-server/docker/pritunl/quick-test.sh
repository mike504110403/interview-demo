#!/bin/bash

echo "═══════════════════════════════════════════════"
echo "🔍 VPN 連接問題快速診斷"
echo "═══════════════════════════════════════════════"
echo ""

echo "1️⃣ 檢查本機 IP："
ifconfig en0 | grep "inet " | awk '{print $2}'
echo ""

echo "2️⃣ 檢查 Docker 端口映射："
docker ps --filter "name=pritunl" --format "{{.Ports}}" | grep 11009
echo ""

echo "3️⃣ 檢查端口監聽："
lsof -i UDP:11009 | grep LISTEN || lsof -i UDP:11009
echo ""

echo "4️⃣ 本機測試 UDP 連接："
nc -z -u -v 192.168.68.106 11009 2>&1
echo ""

echo "5️⃣ 檢查防火牆狀態："
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
echo ""

echo "═══════════════════════════════════════════════"
echo "📋 請同事執行以下測試："
echo "═══════════════════════════════════════════════"
echo ""
echo "A. Ping 測試："
echo "   ping 192.168.68.106"
echo ""
echo "B. 檢查配置文件："
echo "   解壓 .tar，打開 .ovpn"
echo "   第一行應該是："
echo "   remote 192.168.68.106 11009 udp"
echo ""
echo "C. UDP 連接測試："
echo "   nc -u -v 192.168.68.106 11009"
echo ""
echo "D. 檢查同事 IP："
echo "   ifconfig | grep 'inet '"
echo "   應該是 192.168.68.x"
echo ""
echo "═══════════════════════════════════════════════"
