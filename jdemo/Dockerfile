# ==========================================
# 多階段建置 Dockerfile for Spring Boot
# ==========================================

# 階段 1: 建置階段
# 使用最新的 Gradle 版本來支援 Spring Boot 4.0.0
FROM gradle:8.14.0-jdk17 AS builder

# 設定工作目錄
WORKDIR /app

# 複製 Gradle 配置檔案（利用 Docker 快取）
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

# 下載依賴（這層會被快取，除非 build.gradle 改變）
RUN gradle dependencies --no-daemon

# 複製原始碼
COPY src ./src

# 建置應用程式
RUN gradle clean build -x test --no-daemon

# ==========================================
# 階段 2: 運行階段（最終映像檔）
# 使用支援多架構的映像檔 (包含 ARM64 for Apple Silicon)
FROM eclipse-temurin:17-jre

# 設定工作目錄
WORKDIR /app

# 建立非 root 使用者（安全性最佳實踐）
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# 從建置階段複製 JAR 檔案
COPY --from=builder /app/build/libs/*.jar app.jar

# 暴露應用程式埠號
EXPOSE 8080

# 健康檢查（可選）
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/hello?name=health || exit 1

# 啟動應用程式
ENTRYPOINT ["java", "-jar", "app.jar"]

# 可以透過環境變數調整 JVM 參數
# docker run -e JAVA_OPTS="-Xmx512m" myapp
