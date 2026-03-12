import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'command.dart';
import 'suggest_command_provider.dart';
import 'suggest_command_state.dart';

class CommandChatPanel extends ConsumerStatefulWidget {
  const CommandChatPanel({super.key});

  @override
  ConsumerState<CommandChatPanel> createState() => _CommandChatPanelState();
}

class _CommandChatPanelState extends ConsumerState<CommandChatPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    ref.listenManual<SuggestCommandState>(
      suggestCommandProvider,
      (previous, next) {
        final prevCount = previous?.visibleCommands.length ?? 0;
        final nextCount = next.visibleCommands.length;

        if (nextCount > prevCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestCommandProvider);
    final notifier = ref.read(suggestCommandProvider.notifier);
    final commands = state.visibleCommands;

    return Container(
      width: 460,
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
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: commands.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final command = commands[index];
                      final status = state.getStatus(command);
                      final isSending = state.isSending(command);

                      return _AnimatedCommandItem(
                        key: ValueKey(
                          '${SuggestCommandHelper.commandKey(command)}_${command.timestamp.millisecondsSinceEpoch}',
                        ),
                        child: _CommandMessageCard(
                          command: command,
                          status: status,
                          isSending: isSending,
                          onReject: () {
                            notifier.rejectCommand(command);
                          },
                          onSend: () async {
                            try {
                              await notifier.sendCommand(command);
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã gửi command (${command.weaponComplexTrackId} - ${command.trackId})',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gửi command thất bại: $e'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCommandItem extends StatelessWidget {
  final Widget child;

  const _AnimatedCommandItem({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
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
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF1E2A38),
              border: Border.all(color: const Color(0xFF2B3A4D)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/chatbot.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 20,
                );
              },
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
                  'Danh sách đề xuất tác chiến',
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
  final SuggestCommandActionStatus status;
  final bool isSending;
  final VoidCallback onReject;
  final Future<void> Function() onSend;

  const _CommandMessageCard({
    required this.command,
    required this.status,
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
      case CommandType.gayNhieu:
        return 'Gây nhiễu';
      case CommandType.unknown:
        return 'Không xác định';
    }
  }

  Color get commandBadgeBg {
    switch (command.type) {
      case CommandType.tieuDiet:
        return const Color(0xFF8B2E2E);
      case CommandType.gayNhieu:
        return const Color(0xFF5B3B8C);
      case CommandType.bamBat:
        return const Color(0xFF2F5E9C);
      case CommandType.sucSao:
        return const Color(0xFF3E7C43);
      case CommandType.unknown:
        return const Color(0xFF4A4A4A);
    }
  }

  Color get commandBadgeTextColor {
    switch (command.type) {
      case CommandType.tieuDiet:
        return const Color(0xFFFFD6D6);
      case CommandType.gayNhieu:
        return const Color(0xFFE3D5FF);
      case CommandType.bamBat:
        return const Color(0xFFD6E8FF);
      case CommandType.sucSao:
        return const Color(0xFFD8F7D6);
      case CommandType.unknown:
        return const Color(0xFFE0E0E0);
    }
  }

  String get commandDescription {
    switch (command.type) {
      case CommandType.tieuDiet:
        return 'Đề xuất thực hiện lệnh tiêu diệt cho mục tiêu #${command.trackId}.';
      case CommandType.gayNhieu:
        return 'Đề xuất thực hiện lệnh gây nhiễu cho mục tiêu #${command.trackId}.';
      case CommandType.bamBat:
        return 'Đề xuất thực hiện lệnh bám bắt cho mục tiêu #${command.trackId}.';
      case CommandType.sucSao:
        return 'Đề xuất thực hiện lệnh sục sạo cho mục tiêu #${command.trackId}.';
      case CommandType.unknown:
        return 'Đề xuất lệnh cho mục tiêu #${command.trackId}.';
    }
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BotAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF17212B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2B3A4D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Chat Bot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: commandBadgeBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: commandBadgeTextColor.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        commandTypeText,
                        style: TextStyle(
                          color: commandBadgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(command.timestamp),
                      style: const TextStyle(
                        color: Color(0xFF7F8B99),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  commandDescription,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF5),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Command ID', value: '${command.id}'),
                const SizedBox(height: 6),
                _InfoRow(label: 'Track ID', value: '${command.trackId}'),
                const SizedBox(height: 6),
                _InfoRow(
                  label: 'Weapon Complex Track ID',
                  value: command.weaponComplexTrackId,
                ),
                const SizedBox(height: 14),
                _buildBottomArea(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomArea() {
    if (isSending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2F5E9C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Đang gửi...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    switch (status) {
      case SuggestCommandActionStatus.rejected:
        return _StatusBadge(
          text: 'Đã từ chối',
          bgColor: const Color(0xFF5A2E2E),
          textColor: const Color(0xFFFFD6D6),
        );

      case SuggestCommandActionStatus.sent:
        return _StatusBadge(
          text: 'Đã gửi',
          bgColor: const Color(0xFF2E6A4F),
          textColor: const Color(0xFFD8F7D6),
        );

      case SuggestCommandActionStatus.none:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF425266)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Từ chối'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Gửi đi'),
              ),
            ),
          ],
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _StatusBadge({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2B3A4D)),
        color: const Color(0xFF1E2A38),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/chatbot.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 20,
          );
        },
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ),
      ],
    );
  }
}