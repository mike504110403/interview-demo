# 使用輕量級的 nginx 作為靜態文件服務器
FROM nginx:alpine

# 複製所有文件到 nginx 的默認靜態文件目錄
COPY index.html /usr/share/nginx/html/
COPY css/ /usr/share/nginx/html/css/
COPY js/ /usr/share/nginx/html/js/

# 暴露 80 端口
EXPOSE 80

# 啟動 nginx
CMD ["nginx", "-g", "daemon off;"]

