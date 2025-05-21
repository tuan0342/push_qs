#!/bin/bash

# Hướng dẫn sử dụng
# B1: cấp quyền: chmod +x replace-ip.sh
# B2: ./<file>.sh

# Thư mục chứa các file cần xử lý
TARGET_DIR="/usr/share/nginx/html-root-config"

# Danh sách các file cần kiểm tra và thay thế
FILES=("importmap.json" "importmap_style.json" "config.js")

# IP cũ và mới
OLD_IP="144.144.144.144"
NEW_IP="122.122.122.122"

echo "🔍 Đang kiểm tra và thay thế IP trong thư mục: $TARGET_DIR"

# Duyệt qua từng file
for file in "${FILES[@]}"; do
  FILE_PATH="$TARGET_DIR/$file"

  if [[ -f "$FILE_PATH" ]]; then
    echo "✅ Đã tìm thấy: $file — đang thay thế IP..."

    # Thay thế nội dung trong file (in-place)
    sed -i "s/$OLD_IP/$NEW_IP/g" "$FILE_PATH"

    echo "   → Đã thay thế $OLD_IP thành $NEW_IP trong $file"
  else
    echo "⚠️  Không tìm thấy file: $file"
  fi
done

echo "🎉 Hoàn tất!"
