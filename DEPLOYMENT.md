# 部署指南

本簡報是純靜態網站（HTML/CSS/JS），部署非常簡單。以下提供多種部署方案。

---

## 方案一：Vercel（★★★★★ 強烈推薦）

### 優點
- ✅ 完全免費
- ✅ 一鍵部署，無需配置
- ✅ 自動 HTTPS
- ✅ 免費網域（xxx.vercel.app）
- ✅ 全球 CDN 加速
- ✅ 每次 git push 自動部署
- ✅ 支持自定義網域

### 部署步驟

#### 方法 1：使用 Vercel CLI（最快）

```bash
# 1. 安裝 Vercel CLI
npm i -g vercel

# 2. 在專案目錄執行
cd /Users/mike/Documents/self/interview-demo
vercel

# 3. 按照提示操作
# - 登入 Vercel 帳號（可用 GitHub/GitLab/Bitbucket）
# - 確認專案設定
# - 完成！會得到一個 https://xxx.vercel.app 網址
```

#### 方法 2：使用 Vercel 網站（推薦新手）

1. 前往 [vercel.com](https://vercel.com)
2. 用 GitHub 帳號登入
3. 點擊 "Add New Project"
4. 選擇你的 Git repository（需先 push 到 GitHub）
5. 點擊 "Deploy"
6. 完成！自動分配網址

### 配置文件（可選）

在專案根目錄創建 `vercel.json`：

```json
{
  "version": 2,
  "public": true,
  "cleanUrls": true
}
```

---

## 方案二：Netlify（★★★★★ 同樣優秀）

### 優點
- ✅ 完全免費
- ✅ 一鍵部署
- ✅ 自動 HTTPS
- ✅ 免費網域（xxx.netlify.app）
- ✅ 全球 CDN
- ✅ 支持表單、無服務器函數等進階功能

### 部署步驟

#### 方法 1：拖放部署（最簡單）

1. 前往 [app.netlify.com](https://app.netlify.com)
2. 登入（GitHub/GitLab/Bitbucket）
3. 將整個專案資料夾拖放到 Netlify
4. 完成！

#### 方法 2：CLI 部署

```bash
# 1. 安裝 Netlify CLI
npm install -g netlify-cli

# 2. 在專案目錄執行
cd /Users/mike/Documents/self/interview-demo
netlify deploy

# 3. 按照提示操作
# - 登入 Netlify
# - 創建新站點或選擇現有站點
# - 指定部署目錄（選擇當前目錄 .）

# 4. 正式部署（移除 --prod 前的預覽部署）
netlify deploy --prod
```

---

## 方案三：Cloudflare Pages（★★★★☆）

### 優點
- ✅ 完全免費
- ✅ 無限頻寬
- ✅ 全球 CDN（Cloudflare 的 CDN 最強）
- ✅ 自動 HTTPS
- ✅ 免費網域（xxx.pages.dev）

### 部署步驟

1. 前往 [dash.cloudflare.com](https://dash.cloudflare.com)
2. 登入後進入 "Pages"
3. 點擊 "Create a project"
4. 連接 Git repository 或直接上傳檔案
5. 完成！

---

## 方案四：GitHub Pages（★★★☆☆）

### 優點
- ✅ 完全免費
- ✅ 與 GitHub 深度整合
- ✅ 免費網域（username.github.io/repo-name）
- ✅ 支持自定義網域

### 部署步驟

```bash
# 1. 確保代碼已推送到 GitHub

# 2. 在 GitHub repo 設定中：
# Settings → Pages → Source 選擇 main branch

# 3. 或使用 gh-pages 分支部署
npm install -g gh-pages

# 4. 在 package.json 添加
{
  "scripts": {
    "deploy": "gh-pages -d ."
  }
}

# 5. 執行部署
npm run deploy
```

---

## 如果堅持要用 Docker 部署

### 方案五：Render（★★★★☆ 支援 Docker）

#### 優點
- ✅ 有免費方案
- ✅ 支持 Docker
- ✅ 免費網域（xxx.onrender.com）
- ✅ 自動 HTTPS
- ⚠️ 免費方案會休眠（15分鐘無訪問）

#### 部署步驟

1. 創建 `Dockerfile`：

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

2. 前往 [render.com](https://render.com)
3. 創建 "New Web Service"
4. 連接 Git repository
5. 選擇 "Docker" 環境
6. 點擊 "Create Web Service"
7. 完成！

---

### 方案六：Fly.io（★★★★☆ 支援 Docker）

#### 優點
- ✅ 有免費額度
- ✅ 支持 Docker
- ✅ 全球部署
- ✅ 免費網域（xxx.fly.dev）

#### 部署步驟

```bash
# 1. 安裝 flyctl
curl -L https://fly.io/install.sh | sh

# 2. 登入
flyctl auth login

# 3. 在專案目錄初始化
cd /Users/mike/Documents/self/interview-demo
flyctl launch

# 4. 創建 Dockerfile（同上）

# 5. 部署
flyctl deploy

# 6. 開啟網站
flyctl open
```

---

### 方案七：Railway（★★★☆☆ 支援 Docker）

#### 優點
- ✅ $5 免費額度/月
- ✅ 支持 Docker
- ✅ 簡單易用
- ⚠️ 超過額度需付費

#### 部署步驟

1. 前往 [railway.app](https://railway.app)
2. 用 GitHub 登入
3. "New Project" → "Deploy from GitHub repo"
4. 選擇 repository
5. Railway 會自動檢測 Dockerfile 並部署
6. 完成！

---

## 推薦總結

### 最簡單快速（不用 Docker）
1. **Vercel**（首選）- 執行 `vercel` 一行指令搞定
2. **Netlify**（次選）- 拖放檔案即可
3. **Cloudflare Pages** - CDN 最強

### 如果需要用 Docker
1. **Render**（首選）- 免費，支持 Docker
2. **Fly.io** - 全球部署，免費額度
3. **Railway** - 介面友善，$5/月免費額度

---

## 我的建議

**對於這個靜態網站簡報，強烈建議用 Vercel：**

```bash
# 三步驟完成部署
npm i -g vercel
cd /Users/mike/Documents/self/interview-demo
vercel
```

- ✅ 30 秒內完成部署
- ✅ 得到免費 HTTPS 網址
- ✅ 全球 CDN 加速
- ✅ 完全免費
- ✅ 每次 push 自動部署

**不需要 Docker，不需要 docker-compose，不需要配置，開箱即用！**

---

## 自定義網域

所有上述平台都支持自定義網域（你自己的網域），設定步驟：

1. 在平台設定中添加自定義網域
2. 在你的網域 DNS 設定中添加 CNAME 記錄
3. 等待 DNS 生效（幾分鐘到幾小時）
4. 自動配置 HTTPS
5. 完成！

---

## 需要幫助？

如果選擇 Vercel 部署遇到問題，我可以協助您完成部署流程。

