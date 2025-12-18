# Docker 部署指南

## 📦 方法一：使用部署腳本（推薦）

### 快速部署
```bash
# 賦予執行權限
chmod +x deploy-docker.sh

# 執行部署
./deploy-docker.sh
```

### 停止服務
```bash
chmod +x stop-docker.sh
./stop-docker.sh
```

---

## 🔧 方法二：使用 Docker Compose

### 啟動服務
```bash
docker-compose up -d
```

### 查看日誌
```bash
docker-compose logs -f
```

### 停止服務
```bash
docker-compose down
```

---

## 🛠️ 方法三：手動 Docker 命令

### 1. 建置映像檔
```bash
docker build -t jdemo-api:latest .
```

### 2. 啟動容器
```bash
docker run -d \
  --name jdemo-api \
  -p 8080:8080 \
  --restart unless-stopped \
  jdemo-api:latest
```

### 3. 查看日誌
```bash
docker logs -f jdemo-api
```

### 4. 停止並移除
```bash
docker stop jdemo-api
docker rm jdemo-api
```

---

## 🧪 測試 API

部署成功後，可以使用以下命令測試：

```bash
# GET 請求
curl "http://localhost:8080/hello?name=Docker"

# POST 請求
curl -X POST http://localhost:8080/hello \
  -H "Content-Type: application/json" \
  -d '{"name":"Docker","age":25}'

# 其他端點
curl http://localhost:8080/goodbye
curl http://localhost:8080/user
```

---

## 📊 常用 Docker 命令

```bash
# 查看運行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日誌
docker logs jdemo-api

# 即時查看日誌
docker logs -f jdemo-api

# 進入容器內部
docker exec -it jdemo-api sh

# 查看容器資源使用
docker stats jdemo-api

# 重啟容器
docker restart jdemo-api

# 查看映像檔
docker images

# 移除映像檔
docker rmi jdemo-api:latest

# 清理未使用的資源
docker system prune -a
```

---

## 🔍 故障排除

### 問題 1：端口被佔用
```bash
# 查看端口使用
lsof -i :8080

# 停止佔用端口的進程
kill -9 <PID>

# 或使用不同端口
docker run -p 8081:8080 jdemo-api:latest
```

### 問題 2：容器無法啟動
```bash
# 查看詳細日誌
docker logs jdemo-api

# 查看容器詳細資訊
docker inspect jdemo-api
```

### 問題 3：重新建置映像檔
```bash
# 不使用快取重新建置
docker build --no-cache -t jdemo-api:latest .
```

---

## 📈 進階配置

### 調整 JVM 記憶體
```bash
docker run -d \
  --name jdemo-api \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  jdemo-api:latest
```

### 掛載外部配置檔
```bash
docker run -d \
  --name jdemo-api \
  -p 8080:8080 \
  -v $(pwd)/config:/app/config \
  jdemo-api:latest
```

### 連接到網路
```bash
# 建立網路
docker network create jdemo-network

# 加入網路
docker run -d \
  --name jdemo-api \
  --network jdemo-network \
  -p 8080:8080 \
  jdemo-api:latest
```
