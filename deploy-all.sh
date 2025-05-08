#!/bin/bash

# Bước 0: dùng node 18
echo "🟢 Kích hoạt Node 18"
use_node18

BASE_DIR="./microfe"
MAPPING_FILE="./microfe/image-mapping.txt"

# Đọc file ánh xạ tên folder → image list
declare -A IMAGE_MAP

while IFS='=' read -r folder images; do
  IMAGE_MAP["$folder"]="$images"
done < "$MAPPING_FILE"

# Lặp qua từng thư mục micro frontend
for DIR in "$BASE_DIR"/*; do
  if [ -d "$DIR" ]; then
    FOLDER_NAME=$(basename "$DIR")
    IMAGES="${IMAGE_MAP[$FOLDER_NAME]}"

    if [ -z "$IMAGES" ]; then
      echo "⚠️ Bỏ qua $FOLDER_NAME vì không có mapping image."
      continue
    fi

    echo "🚀 Đang xử lý: $FOLDER_NAME"
    cd "$DIR" || continue

    echo "📦 Build frontend..."
    if npm run build; then
      echo "✅ Build thành công"

      # Build và push từng image
      IFS=',' read -ra IMAGE_LIST <<< "$IMAGES"
      for IMAGE in "${IMAGE_LIST[@]}"; do
        echo "🐳 Docker build image: $IMAGE"
        if docker build -t "$IMAGE" .; then
          echo "📤 Push image: $IMAGE"
          if docker push "$IMAGE"; then
            echo "✅ Push thành công: $IMAGE"
          else
            echo "❌ Push thất bại: $IMAGE"
          fi
        else
          echo "❌ Build docker thất bại: $IMAGE"
        fi
      done
    else
      echo "❌ npm build thất bại: $FOLDER_NAME"
    fi

    # Quay lại thư mục gốc
    cd - > /dev/null || exit
  fi
done
