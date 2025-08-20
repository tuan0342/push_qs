import 'package:flutter/material.dart';
import 'package:latlng2/latlng.dart';

/// ---- Model
class AreaObject {
  final String id;
  final String name;
  final List<LatLng> points;
  const AreaObject({
    required this.id,
    required this.name,
    required this.points,
  });
}

/// ---- Reusable panel: Title + scrollable body (CustomScrollView)
class AreaListSection extends StatelessWidget {
  final String title;
  final List<AreaObject> items;
  final void Function(AreaObject area) onView;
  final void Function(AreaObject area) onDelete;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const AreaListSection({
    super.key,
    required this.title,
    required this.items,
    required this.onView,
    required this.onDelete,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor = const Color.fromRGBO(31, 31, 31, 0.85),
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        // Scroll toàn bộ component khi body dài
        slivers: [
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: padding.copyWith(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Count badge
                  _Badge(text: '${items.length}'),
                ],
              ),
            ),
          ),

          // Body (list dọc)
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding,
                child: _EmptyState(),
              ),
            )
          else
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withOpacity(0.06),
              ),
              itemBuilder: (context, index) {
                final area = items[index];
                return _AreaTile(
                  area: area,
                  onView: () => onView(area),
                  onDelete: () => onDelete(area),
                );
              },
            ),
          SliverToBoxAdapter(child: SizedBox(height: padding.vertical / 2)),
        ],
      ),
    );
  }
}

/// ---- Item tile with actions
class _AreaTile extends StatelessWidget {
  final AreaObject area;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _AreaTile({
    required this.area,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtleBg = Colors.white.withOpacity(0.035);
    final textColor = Colors.white;
    final subColor = Colors.white70;

    return Container(
      color: subtleBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar = số điểm
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              '${area.points.length}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
                const SizedBox(height: 2),
                Text(
                  'ID: ${area.id} • ${area.points.length} điểm',
                  style: TextStyle(color: subColor, fontSize: 12.5),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Actions
          Wrap(
            spacing: 8,
            children: [
              _ActionBtn(
                label: 'Xem',
                icon: Icons.visibility_outlined,
                onPressed: onView,
                // Xanh nhẹ hợp nền tối
                fillColor: const Color(0xFF4FC3F7).withOpacity(0.18),
                fgColor: const Color(0xFF4FC3F7),
              ),
              _ActionBtn(
                label: 'Xóa',
                icon: Icons.delete_outline,
                onPressed: onDelete,
                // Đỏ nhạt cho destructive
                fillColor: const Color(0xFFFF6E6E).withOpacity(0.16),
                fgColor: const Color(0xFFFF6E6E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---- Small pill button
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color fillColor;
  final Color fgColor;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.fillColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: fgColor),
      label: Text(label, style: TextStyle(color: fgColor, fontSize: 13)),
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(0, 36)),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
        backgroundColor: MaterialStateProperty.all(fillColor),
        overlayColor: MaterialStateProperty.all(fgColor.withOpacity(0.08)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        side: MaterialStateProperty.all(BorderSide(color: fgColor.withOpacity(0.35), width: 1)),
      ),
    );
  }
}

/// ---- Count badge on the title row
class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// ---- Empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Text(
        'Chưa có vùng nào',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
