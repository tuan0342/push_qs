class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});
  final Aircraft item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh
            AspectRatio(
              aspectRatio: 1,
              child: Ink(
                color: Colors.grey.shade100,
                child: Image.network(
                  item.mediumImageUrl.isNotEmpty
                      ? item.mediumImageUrl
                      : item.smallImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                  loadingBuilder: (c, w, e) {
                    if (e == null) return w;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge nhỏ (ví dụ “0% Trả góp” giả lập)
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '0% trả góp',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: Colors.green.shade700),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Yêu thích',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.model,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),

                  // Ví dụ ô “điểm thưởng”
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 6),
                      Text('Tích điểm +${(item.id % 120) * 100}'),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // Dòng “thông số nhanh” (minh họa)
                  Wrap(
                    spacing: 8,
                    runSpacing: -6,
                    children: [
                      _chip('Tối đa: ${item.maxSpeed}'),
                      _chip('Trần bay: ${item.maxAltitude}'),
                      _chip('Tầm bay: ${item.flightRange}'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nút chi tiết
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Xem chi tiết'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t) => Chip(
        label: Text(t, overflow: TextOverflow.ellipsis),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: Colors.grey.shade300),
      );
}