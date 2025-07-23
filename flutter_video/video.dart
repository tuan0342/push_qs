import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videosVisibleProvider = StateProvider<bool>((ref) => true);

class Videos extends ConsumerStatefulWidget {
  final VoidCallback? onTap;

  const Videos({super.key, this.onTap});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideosState();
}

class _VideosState extends ConsumerState<Videos> {
  Offset? position;
  bool zoomedIn = false;
  int rows = 4;
  int columns = 4;

  late List<Map<String, dynamic>?> gridVideos;

  @override
  void initState() {
    super.initState();
    gridVideos = List.generate(rows * columns, (_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final visible = ref.watch(videosVisibleProvider);
    if (!visible) return Container();

    final screenSize = MediaQuery.sizeOf(context);
    position ??= Offset(90, screenSize.height - 370);

    final Size size = zoomedIn ? const Size(1000, 600) : const Size(500, 300);

    return DraggableResizebleDialog(
      title: 'Video',
      resizable: false,
      hasBackdrop: false,
      initialPosition: position,
      initialSize: size,
      onTap: widget.onTap,
      onClose: () {
        setState(() {
          ref.read(videosVisibleProvider.notifier).state = false;
        });
      },
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoItems(
          zoomedIn: zoomedIn,
          rows: rows,
          columns: columns,
          gridVideos: gridVideos,
          onAssignToGrid: (index, camera) {
            setState(() {
              gridVideos[index] = camera;
            });
          },
          onRemoveFromGrid: (index) {
            setState(() {
              gridVideos[index] = null;
            });
          },
          onChangeGridSize: () async {
            final result = await showDialog<(int, int)>(
              context: context,
              builder: (_) => GridSizeDialog(rows: rows, columns: columns),
            );
            if (result != null) {
              setState(() {
                rows = result.$1;
                columns = result.$2;
                gridVideos = List.generate(rows * columns, (i) =>
                    i < gridVideos.length ? gridVideos[i] : null);
              });
            }
          },
          onToggleZoom: () {
            setState(() {
              zoomedIn = !zoomedIn;
              if (zoomedIn && gridVideos.isEmpty) {
                gridVideos = List.generate(rows * columns, (_) => null);
              }
            });
          },
        ),
      ),
    );
  }
}
