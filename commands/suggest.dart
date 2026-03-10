import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommandChatPanel extends ConsumerWidget {
  const CommandChatPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(suggestCommandProvider);
    final notifier = ref.read(suggestCommandProvider.notifier);
    final commands = state.visibleCommands;

    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF10151C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253041)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 8),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        children: [
          _ChatHeader(commandCount: commands.length),
          const Divider(height: 1, color: Color(0xFF253041)),
          Expanded(
            child: commands.isEmpty
                ? const _EmptyView()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: commands.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final command = commands[index];
                      final isSending =
                          state.sendingIds.contains(command.id);

                      return _CommandMessageCard(
                        command: command,
                        isSending: isSending,
                        onSend: () async {
                          try {
                            await notifier.sendCommand(command);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã gửi command #${command.id}',
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gửi command #${command.id} thất bại',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        onReject: () {
                          notifier.rejectCommand(command.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final int commandCount;

  const _ChatHeader({required this.commandCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Bot Command',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Danh sách đề xuất tiêu diệt',
                  style: TextStyle(
                    color: Color(0xFF9AA8B6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A38),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$commandCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chưa có command đề xuất',
        style: TextStyle(
          color: Color(0xFF9AA8B6),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CommandMessageCard extends StatelessWidget {
  final Command command;
  final bool isSending;
  final VoidCallback onReject;
  final Future<void> Function() onSend;

  const _CommandMessageCard({
    required this.command,
    required this.isSending,
    required this.onReject,
    required this.onSend,
  });

  String get commandTypeText {
    switch (command.type) {
      case CommandType.sucSao:
        return 'Sục sạo';
      case CommandType.bamBat:
        return 'Bám bắt';
      case CommandType.tieuDiet:
        return 'Tiêu diệt';
      case CommandType.unknown:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF17212B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2B3A4D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D1F1F),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    commandTypeText,
                    style: const TextStyle(
                      color: Color(0xFFFFB4B4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${command.id}',
                  style: const TextStyle(
                    color: Color(0xFF9AA8B6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Track ID', value: '${command.trackId}'),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Weapon Complex Track ID',
              value: command.weaponComplexTrackId,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSending ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF425266)),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSending ? null : onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7DFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Gửi đi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF9AA8B6),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}