#!/bin/bash
# chmod +x uninstall-deb.sh


set -e  # Dừng script nếu có lỗi

MAPPING_FILE="deb-rm-mapping.txt"

if [[ ! -f "$MAPPING_FILE" ]]; then
  echo "❌ Không tìm thấy file $MAPPING_FILE"
  exit 1
fi

echo ">>> Đang gỡ các gói được liệt kê trong: $MAPPING_FILE"

while IFS= read -r package_name || [[ -n "$package_name" ]]; do
  if [[ -n "$package_name" ]]; then
    echo ">>> Gỡ package: $package_name"
    sudo dpkg -r "$package_name"
  fi
done < "$MAPPING_FILE"

echo ">>> Gỡ xong tất cả các gói."

echo ">>> Restart nginx..."
sudo systemctl restart nginx.service

echo "✅ Hoàn tất!"
