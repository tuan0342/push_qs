#!/bin/bash

set -e

# Đường dẫn đến file mapping
MAPPING_FILE="deb-mapping.txt"

# Đọc danh sách thư mục từ mapping
declare -A VERSION_MAP
while read -r line; do
    folder=$(echo "$line" | awk '{print $1}')
    version=$(echo "$line" | awk '{print $2}')
    VERSION_MAP["$folder"]="$version"
done < "$MAPPING_FILE"

# Duyệt qua tất cả các thư mục trong project
for dir in */ ; do
    dir=${dir%/}  # bỏ dấu slash cuối

    # Kiểm tra xem thư mục có trong mapping không
    if [[ -n "${VERSION_MAP[$dir]}" ]]; then
        version="${VERSION_MAP[$dir]}"
        echo "==> Đang xử lý thư mục: $dir (version: $version)"

        cd "$dir"

        # Xoá thư mục dist và deb nếu có
        rm -rf dist deb

        # Build project
        if npm run build || true; then
            echo "✅ Build thành công ở $dir"
        else
            echo "❌ Build thất bại ở $dir, bỏ qua"
            cd ..
            continue
        fi

        # Gắn tag git
        git tag -m "Release $version" "$version"

        # Gói deb
        bash pack.sh

        cd ..
    else
        echo "==> Bỏ qua thư mục không có trong mapping: $dir"
    fi
done

echo "🎉 Hoàn tất deploy tất cả dự án."
