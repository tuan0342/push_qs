class MyObjectCard extends StatefulWidget {
  final MyObject obj;
  final VoidCallback? onTap;

  const MyObjectCard({super.key, required this.obj, this.onTap});

  @override
  State<MyObjectCard> createState() => _MyObjectCardState();
}

class _MyObjectCardState extends State<MyObjectCard> {
  bool _hover = false;

  LinearGradient _typeGradient(ObjectType t) {
    // chọn màu tươi nhưng không chói trên nền #1f1f1f
    switch (t) {
      case ObjectType.UUUU:
        return const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ObjectType.AAA:
        return const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF6FCF97)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ObjectType.BBB:
        return const LinearGradient(
          colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ObjectType.CCC:
        return const LinearGradient(
          colors: [Color(0xFF9B51E0), Color(0xFFBB6BD9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _chipBg(ObjectType t) {
    switch (t) {
      case ObjectType.UUUU:
        return const Color(0xFF2F80ED).withOpacity(.15);
      case ObjectType.AAA:
        return const Color(0xFF27AE60).withOpacity(.15);
      case ObjectType.BBB:
        return const Color(0xFFF2994A).withOpacity(.15);
      case ObjectType.CCC:
        return const Color(0xFF9B51E0).withOpacity(.15);
    }
  }

  IconData _typeIcon(ObjectType t) {
    switch (t) {
      case ObjectType.UUUU:
        return Icons.device_hub;
      case ObjectType.AAA:
        return Icons.airplanemode_active;
      case ObjectType.BBB:
        return Icons.directions_boat;
      case ObjectType.CCC:
        return Icons.satellite_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _typeGradient(widget.obj.type);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(31, 31, 31, 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            // viền gradient “fake” bằng alpha khi không hover
            color: Colors.white.withOpacity(_hover ? 0.18 : 0.08),
            width: 1,
          ),
          boxShadow: _hover
              ? [
                  // glow nhẹ khi hover
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: InkWell(
          // tắt splash cho desktop tối
          splashColor: Colors.transparent,
          highlightColor: Colors.white12.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _hover ? 1.01 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // avatar gradient
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _typeIcon(widget.obj.type),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // info block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // name + type chip
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.obj.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _chipBg(widget.obj.type),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                widget.obj.type.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: .2,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // details row
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            _kv('IP', widget.obj.ip),
                            _kv('Lat',
                                widget.obj.lat.toStringAsFixed(4)),
                            _kv('Long',
                                widget.obj.long.toStringAsFixed(4)),
                            _kv('ID', widget.obj.id),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // action chevron có viền gradient subtle
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              const Color.fromRGBO(31, 31, 31, 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$k:',
            style: TextStyle(
              color: Colors.white.withOpacity(.65),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            v,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
            ),
          ),
        ],
      );
}