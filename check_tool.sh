#!/bin/bash
#chmod +x check-deps.sh
#./check-deps.sh

echo "🔍 Đang kiểm tra các gói cần thiết..."

REQUIRED_PACKAGES=(
  libasound2
  libatk-bridge2.0-0
  libatk1.0-0
  libcups2
  libdbus-1-3
  libgdk-pixbuf2.0-0
  libnspr4
  libnss3
  libx11-xcb1
  libxcomposite1
  libxdamage1
  libxrandr2
  xdg-utils
  libu2f-udev
  libvulkan1
  fonts-liberation
)

MISSING=()

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ Tất cả gói đã được cài đặt."
else
  echo "⚠️ Các gói thiếu: ${MISSING[*]}"
  echo "➡️ Cài đặt..."
  sudo apt update
  sudo apt install -y "${MISSING[@]}"
fi
