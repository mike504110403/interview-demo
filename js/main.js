// ============================================
// 簡報控制器
// ============================================

class PresentationController {
    constructor() {
        this.slides = document.querySelectorAll('.slide');
        this.currentSlide = 0;
        this.totalSlides = this.slides.length;
        this.currentPresentation = 'main'; // 當前簡報類型
        
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.updateUI();
        this.setupKeyboardNavigation();
        this.setupTouchNavigation();
    }
    
    setupEventListeners() {
        // 導航按鈕
        document.getElementById('prevBtn').addEventListener('click', () => this.prevSlide());
        document.getElementById('nextBtn').addEventListener('click', () => this.nextSlide());
        
        // Tab 導航
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchPresentation(e.target.dataset.presentation));
        });
    }
    
    // 切換簡報
    switchPresentation(presentationType) {
        if (presentationType === this.currentPresentation) return;
        
        this.currentPresentation = presentationType;
        
        // 找到該簡報的第一頁
        const presentationSlides = Array.from(this.slides).filter(
            slide => slide.dataset.presentation === presentationType
        );
        
        if (presentationSlides.length > 0) {
            const firstSlideIndex = Array.from(this.slides).indexOf(presentationSlides[0]);
            this.goToSlide(firstSlideIndex);
        }
        
        // 更新 tab 按鈕狀態
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.presentation === presentationType);
        });
    }
    
    setupKeyboardNavigation() {
        document.addEventListener('keydown', (e) => {
            switch(e.key) {
                case 'ArrowLeft':
                case 'ArrowUp':
                    e.preventDefault();
                    this.prevSlide();
                    break;
                case 'ArrowRight':
                case 'ArrowDown':
                case ' ':
                    e.preventDefault();
                    this.nextSlide();
                    break;
                case 'Home':
                    e.preventDefault();
                    this.goToSlide(0);
                    break;
                case 'End':
                    e.preventDefault();
                    this.goToSlide(this.totalSlides - 1);
                    break;
            }
        });
    }
    
    setupTouchNavigation() {
        let touchStartX = 0;
        let touchEndX = 0;
        
        const slidesContainer = document.querySelector('.slides');
        
        slidesContainer.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
        });
        
        slidesContainer.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            this.handleSwipe();
        });
        
        const handleSwipe = () => {
            if (touchEndX < touchStartX - 50) {
                this.nextSlide();
            }
            if (touchEndX > touchStartX + 50) {
                this.prevSlide();
            }
        };
        
        this.handleSwipe = handleSwipe;
    }
    
    goToSlide(index) {
        if (index < 0 || index >= this.totalSlides) return;
        
        // 移除當前 active 狀態
        this.slides[this.currentSlide].classList.remove('active');
        if (index > this.currentSlide) {
            this.slides[this.currentSlide].classList.add('prev');
        }
        
        // 設置新的 active 狀態
        this.currentSlide = index;
        this.slides[this.currentSlide].classList.remove('prev');
        this.slides[this.currentSlide].classList.add('active');
        
        // 更新當前簡報類型
        this.currentPresentation = this.slides[this.currentSlide].dataset.presentation;
        
        // 更新 tab 按鈕狀態
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.presentation === this.currentPresentation);
        });
        
        this.updateUI();
        this.updateURL();
    }
    
    nextSlide() {
        // 獲取當前簡報的所有頁面
        const currentPresentationSlides = Array.from(this.slides).filter(
            slide => slide.dataset.presentation === this.currentPresentation
        );
        
        // 找到當前頁在當前簡報中的索引
        const currentIndexInPresentation = currentPresentationSlides.findIndex(
            slide => Array.from(this.slides).indexOf(slide) === this.currentSlide
        );
        
        // 如果不是最後一頁，切換到下一頁
        if (currentIndexInPresentation < currentPresentationSlides.length - 1) {
            const nextSlideInPresentation = currentPresentationSlides[currentIndexInPresentation + 1];
            const nextSlideIndex = Array.from(this.slides).indexOf(nextSlideInPresentation);
            this.goToSlide(nextSlideIndex);
        }
    }
    
    prevSlide() {
        // 獲取當前簡報的所有頁面
        const currentPresentationSlides = Array.from(this.slides).filter(
            slide => slide.dataset.presentation === this.currentPresentation
        );
        
        // 找到當前頁在當前簡報中的索引
        const currentIndexInPresentation = currentPresentationSlides.findIndex(
            slide => Array.from(this.slides).indexOf(slide) === this.currentSlide
        );
        
        // 如果不是第一頁，切換到上一頁
        if (currentIndexInPresentation > 0) {
            const prevSlideInPresentation = currentPresentationSlides[currentIndexInPresentation - 1];
            const prevSlideIndex = Array.from(this.slides).indexOf(prevSlideInPresentation);
            this.goToSlide(prevSlideIndex);
        }
    }
    
    updateUI() {
        // 獲取當前簡報的所有頁面
        const currentPresentationSlides = Array.from(this.slides).filter(
            slide => slide.dataset.presentation === this.currentPresentation
        );
        
        // 計算當前頁在當前簡報中的位置
        const currentPresentationIndex = currentPresentationSlides.findIndex(
            slide => Array.from(this.slides).indexOf(slide) === this.currentSlide
        );
        
        // 更新頁碼顯示（只顯示當前簡報的頁數）
        document.getElementById('pageCounter').textContent = 
            `${currentPresentationIndex + 1} / ${currentPresentationSlides.length}`;
        
        // 更新按鈕狀態（基於當前簡報）
        const isFirstSlideOfPresentation = currentPresentationIndex === 0;
        const isLastSlideOfPresentation = currentPresentationIndex === currentPresentationSlides.length - 1;
        
        document.getElementById('prevBtn').disabled = isFirstSlideOfPresentation;
        document.getElementById('nextBtn').disabled = isLastSlideOfPresentation;
    }
    
    updateURL() {
        const url = new URL(window.location);
        url.searchParams.set('slide', this.currentSlide);
        window.history.pushState({}, '', url);
    }
    
    loadFromURL() {
        const params = new URLSearchParams(window.location.search);
        const slideParam = params.get('slide');
        if (slideParam !== null) {
            const slideIndex = parseInt(slideParam);
            if (!isNaN(slideIndex) && slideIndex >= 0 && slideIndex < this.totalSlides) {
                this.goToSlide(slideIndex);
            }
        }
    }
}

// ============================================
// Demo 控制
// ============================================

function showDemo(demoType) {
    const demoURLs = {
        'webrtc': 'http://localhost:3000',  // WebRTC Demo
        'stream': 'http://localhost:5173',   // Stream Demo
        'golden': 'http://localhost:5173'    // Golden Buy Demo
    };
    
    const demoURL = demoURLs[demoType];
    if (demoURL) {
        // 在新視窗開啟 demo
        window.open(demoURL, '_blank', 'width=1280,height=720');
    }
}

function showDemoLinks() {
    presentation.goToSlide(21); // 跳轉到 Demo 展示頁
}

function openDemoWindow(demoType) {
    showDemo(demoType);
}

function closeDemoModal() {
    document.getElementById('demoModal').classList.remove('active');
}

// ============================================
// 初始化
// ============================================

let presentation;

document.addEventListener('DOMContentLoaded', () => {
    presentation = new PresentationController();
    presentation.loadFromURL();
    
    // 添加平滑滾動行為
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // 全局函數供 HTML 調用
    window.goToSlide = (index) => presentation.goToSlide(index);
    window.showDemo = showDemo;
    window.showDemoLinks = showDemoLinks;
    window.openDemoWindow = openDemoWindow;
    window.closeDemoModal = closeDemoModal;
});

// ============================================
// 輔助功能
// ============================================

// 防止右鍵菜單（可選）
// document.addEventListener('contextmenu', e => e.preventDefault());

// 禁用選擇文字（可選）
// document.addEventListener('selectstart', e => e.preventDefault());

// 全螢幕模式
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        }
    }
}

// F11 切換全螢幕
document.addEventListener('keydown', (e) => {
    if (e.key === 'F11') {
        e.preventDefault();
        toggleFullscreen();
    }
    
    // Esc 退出全螢幕或關閉 Modal
    if (e.key === 'Escape') {
        if (document.fullscreenElement) {
            document.exitFullscreen();
        }
        closeDemoModal();
    }
});

// ============================================
// 效能優化
// ============================================

// Lazy loading 圖片
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                observer.unobserve(img);
            }
        });
    });
    
    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// 預載下一張簡報的圖片
function preloadNextSlide() {
    const nextSlide = presentation.currentSlide + 1;
    if (nextSlide < presentation.totalSlides) {
        const nextSlideElement = presentation.slides[nextSlide];
        const images = nextSlideElement.querySelectorAll('img[data-src]');
        images.forEach(img => {
            if (img.dataset.src) {
                const tempImg = new Image();
                tempImg.src = img.dataset.src;
            }
        });
    }
}

// ============================================
// 分析與追蹤（可選）
// ============================================

function trackSlideView(slideIndex) {
    // 可以在這裡添加 Google Analytics 或其他分析工具
    console.log(`Viewing slide ${slideIndex + 1}`);
}

// ============================================
// 輔助工具
// ============================================

// 複製程式碼片段
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showToast('已複製到剪貼簿');
    }).catch(err => {
        console.error('複製失敗:', err);
    });
}

// 顯示提示訊息
function showToast(message, duration = 2000) {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        bottom: 80px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(0, 0, 0, 0.8);
        color: white;
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 14px;
        z-index: 10000;
        animation: fadeInOut ${duration}ms ease-in-out;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.remove();
    }, duration);
}

// 添加動畫樣式
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInOut {
        0% { opacity: 0; transform: translate(-50%, 20px); }
        10% { opacity: 1; transform: translate(-50%, 0); }
        90% { opacity: 1; transform: translate(-50%, 0); }
        100% { opacity: 0; transform: translate(-50%, -20px); }
    }
`;
document.head.appendChild(style);

// ============================================
// Debug 模式（開發用）
// ============================================

if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    // 顯示簡報編號
    window.showSlideNumbers = () => {
        document.querySelectorAll('.slide').forEach((slide, index) => {
            const number = document.createElement('div');
            number.style.cssText = `
                position: absolute;
                top: 10px;
                right: 10px;
                background: rgba(0, 0, 0, 0.7);
                color: white;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: bold;
                z-index: 100;
            `;
            number.textContent = index + 1;
            slide.appendChild(number);
        });
        console.log('Slide numbers displayed');
    };
    
    // 快速跳轉（開發用）
    window.dev = {
        goto: (n) => presentation.goToSlide(n - 1),
        next: () => presentation.nextSlide(),
        prev: () => presentation.prevSlide(),
        current: () => presentation.currentSlide + 1,
        total: () => presentation.totalSlides
    };
    
    console.log('Debug mode enabled. Use window.dev.goto(n) to jump to slide n');
}

