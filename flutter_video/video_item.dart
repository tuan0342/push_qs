class VideoItems extends StatefulWidget {
  final bool zoomedIn;
  final int rows;
  final int columns;
  final List<Map<String, dynamic>?> gridVideos;
  final void Function(int index, Map<String, dynamic> camera) onAssignToGrid;
  final void Function(int index) onRemoveFromGrid;
  final VoidCallback onToggleZoom;
  final VoidCallback onChangeGridSize;

  const VideoItems({
    super.key,
    required this.zoomedIn,
    required this.rows,
    required this.columns,
    required this.gridVideos,
    required this.onAssignToGrid,
    required this.onRemoveFromGrid,
    required this.onToggleZoom,
    required this.onChangeGridSize,
  });

  @override
  State<VideoItems> createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  int? selectedIndex;

  final items = [
    {'title': 'Camera 1', 'icon': Icons.camera_alt},
    {'title': 'Camera 2', 'icon': Icons.videocam},
    {'title': 'Camera 3', 'icon': Icons.security},
    {'title': 'Camera 4', 'icon': Icons.cameraswitch},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Danh sách camera bên trái
        SizedBox(
          width: 150,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Draggable<Map<String, dynamic>>(
                data: item,
                feedback: Material(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade200,
                    child: Text(item['title']),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.4, child: CameraListItem(item: item)),
                child: CameraListItem(item: item),
              );
            },
          ),
        ),
        const VerticalDivider(),
        // Nội dung bên phải
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(widget.zoomedIn ? Icons.zoom_out_map : Icons.zoom_in_map),
                      onPressed: widget.onToggleZoom,
                      tooltip: widget.zoomedIn ? 'Thu nhỏ' : 'Phóng to',
                    ),
                    if (widget.zoomedIn)
                      IconButton(
                        icon: const Icon(Icons.grid_on),
                        onPressed: widget.onChangeGridSize,
                        tooltip: 'Chỉnh kích thước lưới',
                      ),
                  ],
                ),
                Expanded(
                  child: widget.zoomedIn
                      ? GridVideoView(
                          rows: widget.rows,
                          columns: widget.columns,
                          videos: widget.gridVideos,
                          onDropVideo: widget.onAssignToGrid,
                          onRemoveVideo: widget.onRemoveFromGrid,
                        )
                      : Container(
                          width: 400,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Center(child: RtspPlayerWidget()),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CameraListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const CameraListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(item['icon']),
          const SizedBox(width: 8),
          Text(item['title']),
        ],
      ),
    );
  }
}
