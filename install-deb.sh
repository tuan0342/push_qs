#!/bin/bash
#chmod +x install-all.sh

set -e  # Dừng script nếu có lỗi xảy ra

DEB_DIR="./mfe-deb"

echo ">>> Đang cài đặt các gói .deb trong thư mục: $DEB_DIR"

# Lặp qua tất cả các file .deb trong thư mục
for deb_file in "$DEB_DIR"/*.deb; do
  if [[ -f "$deb_file" ]]; then
    echo ">>> Cài đặt: $deb_file"
    sudo dpkg -i "$deb_file"
  fi
done

echo ">>> Đã cài đặt xong tất cả .deb"

echo ">>> Restart nginx..."
sudo systemctl restart nginx.service

echo "✅ Hoàn tất!"
