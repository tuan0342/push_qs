// docker build -t tool-capture-screen .
// linux: docker run --rm \
//  -v $(pwd)/env.json:/app/env.json \
//  -v ~/screenshots:/root/Downloads \
//  tool-capture-screen

// windown: docker run --rm `
//  -v ${PWD}/env.json:/app/env.json `
//  -v ${HOME}/screenshots:/root/Downloads `
//  tool-capture-screen


const puppeteer = require("puppeteer");
const fs = require("fs");
const path = require("path");
const os = require("os");

// 🔽 Đọc env.json (nằm cùng thư mục hoặc bind mount vào khi chạy Docker)
let config;
try {
  const envPath = path.join(__dirname, "env.json");
  config = JSON.parse(fs.readFileSync(envPath, "utf-8"));
} catch (err) {
  console.error("Không thể đọc file env.json:", err.message);
  process.exit(1);
}

const url = config.url;
let executablePath = config.executablePath;

// 🔽 Nếu không chỉ định Chrome path, tự chọn theo hệ điều hành
if (!executablePath) {
  switch (os.platform()) {
    case "win32":
      executablePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
      break;
    case "linux":
      executablePath = "/usr/bin/google-chrome";
      break;
    case "darwin":
      executablePath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
      break;
    default:
      console.error("Không thể xác định hệ điều hành.");
      process.exit(1);
  }
}

if (!url) {
  console.log("Thiếu url trong file env.json");
  process.exit(1);
}

const downloadsDir = path.join(os.homedir(), "Downloads", "capture-fe");
if (!fs.existsSync(downloadsDir)) {
  fs.mkdirSync(downloadsDir, { recursive: true });
  console.log(`📁 Đã tạo thư mục: ${downloadsDir}`);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath,
    headless: false,
    args: ["--start-maximized"],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1080 });
  await page.goto(url, { timeout: 60000 });

  const interval = setInterval(async () => {
    try {
      const now = new Date();
      const timestamp = `${String(now.getDate()).padStart(2, "0")}-${String(now.getMonth() + 1).padStart(2, "0")}-${now.getFullYear()}-${String(now.getHours()).padStart(2, "0")}-${String(now.getMinutes()).padStart(2, "0")}-${String(now.getSeconds()).padStart(2, "0")}-${String(now.getMilliseconds()).padStart(3, "0")}`;
      const filePath = path.join(downloadsDir, `screenshot-${timestamp}.png`);
      await page.screenshot({ path: filePath, fullPage: true });
      console.log(`📸 Đã lưu ảnh: ${filePath}`);
    } catch (err) {
      console.error("Lỗi khi chụp màn hình:", err);
    }
  }, 2000);

  browser.on("disconnected", () => {
    console.log("🔚 Trình duyệt đã đóng. Kết thúc chương trình.");
    clearInterval(interval);
    process.exit(0);
  });

  process.on("SIGINT", async () => {
    console.log("🛑 Đang thoát...");
    clearInterval(interval);
    if (browser && browser.isConnected()) {
      try {
        await browser.close();
      } catch (err) {
        console.warn("⚠️ Không thể đóng trình duyệt:", err.message);
      }
    }
    process.exit(0);
  });
})();
