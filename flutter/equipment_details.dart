class ObjectListViewCreative extends StatelessWidget {
  final List<MyObject> objects;
  final VoidCallback onBack;
  final String? title;

  const ObjectListViewCreative({
    super.key,
    required this.objects,
    required this.onBack,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // khớp format sẵn của bạn
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              // Back button
              TextButton.icon(
                onPressed: onBack,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  backgroundColor: const Color.fromRGBO(31, 31, 31, 0.85),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text(
                  'Quay lại',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Danh sách thiết bị',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Danh sách (dọc)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final obj in objects)
                    MyObjectCard(
                      obj: obj,
                      onTap: () {
                        // tuỳ ý: mở chi tiết, show popup, v.v.
                        debugPrint('Open ${obj.name}');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
