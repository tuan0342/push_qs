#!/bin/bash

echo "🧹 Đang tìm và xóa các Docker image chứa 'micro-fe' trong tên..."

# Lấy danh sách image ID có tên chứa "micro-fe"
IMAGE_IDS=$(docker images --format "{{.Repository}} {{.ID}}" | grep "micro-fe" | awk '{print $2}')

if [ -z "$IMAGE_IDS" ]; then
  echo "✅ Không tìm thấy image nào chứa 'micro-fe'."
  exit 0
fi

# Xóa từng image
for IMAGE_ID in $IMAGE_IDS; do
  echo "🗑️  Xóa image ID: $IMAGE_ID"
  docker rmi -f "$IMAGE_ID"
done

echo "✅ Hoàn tất."
