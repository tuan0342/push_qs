# ✅ Base image có Chrome + dependencies cần thiết để Puppeteer chạy
FROM debian:bullseye

# ✅ Tạo thư mục làm việc
WORKDIR /app

# ✅ Cài Node.js LTS + Chrome + các lib hỗ trợ GUI
RUN apt-get update && apt-get install -y \
  curl gnupg wget ca-certificates unzip fonts-liberation \
  libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 \
  libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 \
  libxcomposite1 libxdamage1 libxrandr2 xdg-utils libu2f-udev \
  libvulkan1 \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && apt-get install -y ./google-chrome-stable_current_amd64.deb \
  && rm google-chrome-stable_current_amd64.deb \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# ✅ Copy mã nguồn vào container
COPY . .

# ✅ Cài dependencies và bỏ tải Chromium
ENV PUPPETEER_SKIP_DOWNLOAD=true
RUN npm install

# ✅ Chạy tool (giả sử bạn đã dùng env.json)
CMD ["node", "index.js"]
