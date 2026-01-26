import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* =========================
   APP ROOT
========================= */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/* =========================
   HOME PAGE
========================= */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F33),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showKanbanCommandDialog(context),
          child: const Text('Open Kanban Command Dialog'),
        ),
      ),
    );
  }
}

/* =========================
   SHOW DIALOG
========================= */
void showKanbanCommandDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const KanbanCommandDialog(),
  );
}

/* =========================
   DATA MODELS
========================= */
enum TargetStatus { tracking, pending }

class TargetItem {
  final String id;
  final String type;
  final String speed;
  final String altitude;
  final TargetStatus status;

  TargetItem({
    required this.id,
    required this.type,
    required this.speed,
    required this.altitude,
    required this.status,
  });
}

class PaginationState {
  final int page;
  final int pageSize;
  final int total;

  PaginationState({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  int get totalPages => (total / pageSize).ceil();
}

/* =========================
   MAIN DIALOG
========================= */
class KanbanCommandDialog extends StatefulWidget {
  const KanbanCommandDialog({super.key});

  @override
  State<KanbanCommandDialog> createState() => _KanbanCommandDialogState();
}

class _KanbanCommandDialogState extends State<KanbanCommandDialog> {
  int currentPage = 1;
  final int pageSize = 5;
  final int totalItems = 57;

  List<TargetItem> items = [];

  @override
  void initState() {
    super.initState();
    fetchTargets(page: currentPage);
  }

  void fetchTargets({required int page}) {
    // 🔴 MOCK API (bạn thay bằng API thật)
    final start = (page - 1) * pageSize;
    items = List.generate(pageSize, (i) {
      final index = start + i + 1;
      return TargetItem(
        id: 'UAV $index',
        type: index % 4 == 0 ? 'Reconnaissance UAV' : 'Commercial Drone',
        speed: '45 km/h',
        altitude: '1200 m',
        status: TargetStatus.tracking,
      );
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 1200,
        height: 720,
        decoration: BoxDecoration(
          color: const Color(0xFF123B5D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _Header(onClose: () => Navigator.pop(context)),
            const _Toolbar(),
            const _KanbanHeader(),
            Expanded(child: _KanbanList(items: items)),
            PaginationFooter(
              pagination: PaginationState(
                page: currentPage,
                pageSize: pageSize,
                total: totalItems,
              ),
              onPageChanged: (page) {
                currentPage = page;
                fetchTargets(page: page);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   HEADER
========================= */
class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0E2F4A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Text(
            'Bảng điều khiển tác chiến',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/* =========================
   TOOLBAR
========================= */
class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _Tab('Trung tâm chiến đấu', active: true),
          const SizedBox(width: 8),
          _Tab('Báo cáo đánh chặn'),
          const Spacer(),
          SizedBox(
            width: 220,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0E2F4A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Tìm mục tiêu'),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool active;
  const _Tab(this.text, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1E88E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/* =========================
   KANBAN HEADER
========================= */
class _KanbanHeader extends StatelessWidget {
  const _KanbanHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1B4E73),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderCell('Phát hiện', Colors.lightBlue)),
          Expanded(flex: 2, child: _HeaderCell('Phân loại', Colors.orange)),
          Expanded(flex: 2, child: _HeaderCell('Chỉ thị', Colors.redAccent)),
          Expanded(flex: 2, child: _HeaderCell('Trạng thái', Colors.green)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final Color color;
  const _HeaderCell(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

/* =========================
   KANBAN LIST
========================= */
class _KanbanList extends StatelessWidget {
  final List<TargetItem> items;
  const _KanbanList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _KanbanRow(item: items[i]),
    );
  }
}

class _KanbanRow extends StatelessWidget {
  final TargetItem item;
  const _KanbanRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF174A70),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.id,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${item.speed}, ${item.altitude}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child:
                Text(item.type, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Chọn khí tài bám bắt',
                dropdownColor: const Color(0xFF0E2F4A),
                items: const [
                  DropdownMenuItem(
                    value: 'Chọn khí tài bám bắt',
                    child: Text('Chọn khí tài bám bắt'),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Đang theo dõi',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   PAGINATION FOOTER
========================= */
class PaginationFooter extends StatelessWidget {
  final PaginationState pagination;
  final ValueChanged<int> onPageChanged;

  const PaginationFooter({
    super.key,
    required this.pagination,
    required this.onPageChanged,
  });

  List<int?> _buildPages() {
    final total = pagination.totalPages;
    final current = pagination.page;
    final pages = <int?>[];

    if (total <= 7) {
      for (int i = 1; i <= total; i++) pages.add(i);
    } else {
      pages.add(1);
      if (current > 4) pages.add(null);
      for (int i = current - 1; i <= current + 1; i++) {
        if (i > 1 && i < total) pages.add(i);
      }
      if (current < total - 3) pages.add(null);
      pages.add(total);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF0E2F4A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            label: '< Back',
            enabled: pagination.page > 1,
            onTap: () => onPageChanged(pagination.page - 1),
          ),
          const SizedBox(width: 12),
          ...pages.map((p) => _PageItem(
                page: p,
                current: pagination.page,
                onTap: p != null ? () => onPageChanged(p) : null,
              )),
          const SizedBox(width: 12),
          _NavButton(
            label: 'Next >',
            enabled: pagination.page < pagination.totalPages,
            onTap: () => onPageChanged(pagination.page + 1),
          ),
        ],
      ),
    );
  }
}

class _PageItem extends StatelessWidget {
  final int? page;
  final int current;
  final VoidCallback? onTap;

  const _PageItem({
    required this.page,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (page == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('...', style: TextStyle(color: Colors.white70)),
      );
    }

    final active = page == current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Text(
        label,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white38,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
