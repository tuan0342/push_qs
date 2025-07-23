class GridVideoView extends StatefulWidget {
  final int rows;
  final int columns;
  final List<Map<String, dynamic>?> videos;
  final void Function(int index, Map<String, dynamic> camera) onDropVideo;
  final void Function(int index) onRemoveVideo;

  const GridVideoView({
    super.key,
    required this.rows,
    required this.columns,
    required this.videos,
    required this.onDropVideo,
    required this.onRemoveVideo,
  });

  @override
  State<GridVideoView> createState() => _GridVideoViewState();
}

class _GridVideoViewState extends State<GridVideoView> {
  int? hoveredIndex;
  int? tappedIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.rows * widget.columns,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        return DragTarget<Map<String, dynamic>>(
          onAccept: (data) {
            widget.onDropVideo(index, data);
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  tappedIndex = tappedIndex == index ? null : index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.green
                        : Colors.grey.shade500,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: video != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(video['icon'], color: Colors.white),
                                const SizedBox(height: 4),
                                Text(video['title'],
                                    style: const TextStyle(
                                        color: Colors.white)),
                              ],
                            )
                          : const Icon(Icons.add,
                              color: Colors.white24, size: 36),
                    ),
                    if (tappedIndex == index && video != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => widget.onRemoveVideo(index),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
