# 使用 APITemplate.io 轉換企劃書為 PDF 的完整指南

## 一、準備工作

### 1.1 文件準備

使用以下優化過的 Markdown 文件：
- `企劃書-階段性伺服器採購計劃-GoogleDocs版.md`
- `企劃書-團隊技術調整規劃-GoogleDocs版.md`

### 1.2 自定義 CSS

使用配套的樣式文件：
- `custom-pdf-style.css`

## 二、操作步驟

### 步驟 1：打開工具

1. 前往 https://apitemplate.io/pdf-tools/convert-markdown-to-pdf/
2. 看到三個區塊：Markdown、Custom CSS、HTML Preview

### 步驟 2：貼上 Markdown 內容

1. 打開 `企劃書-階段性伺服器採購計劃-GoogleDocs版.md`
2. 複製全部內容（Cmd+A, Cmd+C）
3. 貼到 APITemplate.io 左邊的 **Markdown** 編輯器中

### 步驟 3：貼上自定義 CSS

1. 打開 `custom-pdf-style.css`
2. 複製全部內容
3. 貼到中間的 **Custom CSS** 編輯器中

### 步驟 4：預覽確認

1. 右邊的 **HTML Preview** 會即時顯示效果
2. 檢查以下項目：
   - 標題大小是否合適
   - 表格是否完整顯示
   - 甘特圖符號是否正確
   - 分頁位置是否合理

### 步驟 5：生成 PDF

1. 點擊 **Generate PDF** 按鈕
2. 等待幾秒鐘處理
3. 點擊 **Download PDF** 下載檔案

### 步驟 6：重複處理第二份企劃書

1. 清空 Markdown 編輯器
2. 貼上 `企劃書-團隊技術調整規劃-GoogleDocs版.md` 內容
3. CSS 保持不變（已經貼好了）
4. 再次生成並下載

## 三、使用限制與注意事項

### 3.1 工具限制

- **每小時最多 10 個 PDF**：如果超過需等待下一小時
- **PDF 有效期 2 小時**：請及時下載保存
- **免費使用**：完全免費，無需註冊

### 3.2 檔案命名建議

下載後建議重新命名：
- `階段性伺服器採購計劃_2024-12-25.pdf`
- `團隊技術調整規劃_2024-12-25.pdf`

## 四、常見問題與解決方案

### 4.1 甘特圖顯示問題

**問題：** 甘特圖的 ■ 符號顯示為方框或問號

**解決方案：**
- 這是字體支持問題
- 在 Custom CSS 中已設定 `font-family: 'Microsoft YaHei', 'Arial Unicode MS'`
- 如果仍有問題，可以在預覽時確認，PDF 通常會正確顯示

### 4.2 表格跨頁問題

**問題：** 表格在分頁時被切割

**解決方案：**
- CSS 中已設定 `page-break-inside: avoid`
- 如果表格太大，考慮拆分成多個小表格
- 或調整文字大小（在 CSS 中修改 `font-size`）

### 4.3 中文字體問題

**問題：** 中文顯示不正常

**解決方案：**
- CSS 中已設定多個中文字體作為備選
- APITemplate.io 支援中文，應該不會有問題
- 如果有問題，可以調整 CSS 中的 `font-family`

### 4.4 PDF 太暗或太淺

**問題：** 顏色不合適

**解決方案：**
可以在 CSS 中調整顏色：

```css
/* 調整標題顏色 */
h1 {
    color: #1a1a1a;  /* 更深或更淺 */
}

/* 調整表格背景 */
tbody tr:nth-child(even) {
    background-color: #f8f9fa;  /* 調整斑馬紋顏色 */
}
```

### 4.5 分頁位置不理想

**問題：** 內容在不合適的地方分頁

**解決方案：**
1. 在 Markdown 中的分頁提示處會自動分頁
2. 如需手動調整，在 Markdown 中加入：
   ```markdown
   ---
   *（以下內容分頁）*
   ---
   ```

## 五、進階自定義

### 5.1 調整字體大小

在 `custom-pdf-style.css` 中修改：

```css
body {
    font-size: 11pt;  /* 調整正文大小：10pt-12pt */
}

h1 {
    font-size: 28pt;  /* 調整主標題：24pt-32pt */
}

table {
    font-size: 10pt;  /* 調整表格：9pt-11pt */
}
```

### 5.2 調整表格樣式

```css
/* 改變表格標題背景色 */
th {
    background-color: #2c3e50;  /* 深藍 */
    /* 或 #27ae60 綠色 */
    /* 或 #e74c3c 紅色 */
}

/* 改變斑馬紋顏色 */
tbody tr:nth-child(even) {
    background-color: #f0f0f0;  /* 更深的灰 */
}
```

### 5.3 調整頁邊距

```css
body {
    padding: 40px 50px;  /* 上下40px 左右50px */
    /* 可改為 padding: 30px 40px; 讓內容更緊湊 */
}
```

## 六、快速檢查清單

轉換前檢查：
- [ ] Markdown 文件內容完整
- [ ] CSS 文件已貼入
- [ ] HTML Preview 顯示正常
- [ ] 表格格式正確
- [ ] 甘特圖符號顯示正常
- [ ] 分頁位置合理

轉換後檢查：
- [ ] PDF 下載成功
- [ ] 檔案大小合理（約 100-300 KB）
- [ ] 用 PDF 閱讀器打開測試
- [ ] 所有頁面內容完整
- [ ] 表格和圖表清晰
- [ ] 沒有亂碼或缺失內容

## 七、替代方案

如果 APITemplate.io 遇到問題，可以使用：

### 方案 A：Pandoc（需安裝）

```bash
pandoc 企劃書-階段性伺服器採購計劃-GoogleDocs版.md \
  -o 採購企劃書.pdf \
  --pdf-engine=xelatex \
  -V CJKmainfont="Microsoft YaHei"
```

### 方案 B：Typora（需購買）

1. 用 Typora 打開 Markdown 文件
2. File → Export → PDF
3. 選擇主題和樣式
4. 導出

### 方案 C：Markdown → DOCX → PDF

```bash
# 先轉 DOCX
pandoc 企劃書-階段性伺服器採購計劃-GoogleDocs版.md -o 採購企劃書.docx

# 然後用 Word 或 Google Docs 轉 PDF
```

## 八、技巧與建議

### 8.1 最佳實踐

1. **先預覽，再生成**：充分利用實時預覽功能
2. **保存 CSS**：custom-pdf-style.css 可重複使用
3. **批量處理**：兩份企劃書用同一個 CSS
4. **及時下載**：生成後立即下載（2小時過期）

### 8.2 提升效率

1. **收藏網址**：把工具網址加入書籤
2. **準備模板**：CSS 文件固定後就不用改
3. **版本管理**：下載的 PDF 加上日期版本號

## 九、聯繫支援

如果遇到技術問題：
- APITemplate.io 官網：https://apitemplate.io
- 郵件支援：[email protected]

---

**祝您轉換順利！**

