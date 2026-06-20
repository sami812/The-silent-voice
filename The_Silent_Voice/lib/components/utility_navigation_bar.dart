import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/services/stt_service.dart';
import 'package:the_silent_voice/services/tts_service.dart';

/// ### Component 3: utility bar
///
/// - a smaller navigation bar at the bottom of the screen
/// - left button saves the conversation to history
/// - right button opens the keyboard to write a custom message
/// - the center circle is a 4-way swipe gesture:
///     - swipe left  -> "Yes"
///     - swipe right -> "No"
///     - swipe up    -> "Can you repeat what you said again?"
///     - swipe down  -> cancel (no action)
///
/// All gesture output and custom/suggested text go through the same TTS
/// pipeline used elsewhere in the app.

/// The 4 directions the gesture circle can resolve to.
/// Using a single enum + single resolver function (instead of separate
/// angle math for "what's highlighted" vs "what action fires") means the
/// highlighted segment always matches what actually happens on release.
enum _Segment { yes, no, repeat, cancel, none }

/// Minimum drag distance (in px) before a direction is registered, so a
/// stray tap/jitter doesn't accidentally trigger an action.
const double _minDragDistance = 12;

_Segment _resolveSegment(Offset delta) {
  if (delta.distance < _minDragDistance) return _Segment.none;
  // Whichever axis moved further decides the direction.
  return delta.dx.abs() > delta.dy.abs()
      ? (delta.dx < 0 ? _Segment.yes : _Segment.no)
      : (delta.dy < 0 ? _Segment.repeat : _Segment.cancel);
}

class UtilityNavigationBar extends StatefulWidget {
  const UtilityNavigationBar({super.key});
  @override
  State<UtilityNavigationBar> createState() => _UtilityNavigationBarState();
}

class _UtilityNavigationBarState extends State<UtilityNavigationBar>
    with SingleTickerProviderStateMixin {
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isDragging = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _Segment get _activeSegment {
    if (_dragStart == null || _dragCurrent == null) return _Segment.none;
    return _resolveSegment(_dragCurrent! - _dragStart!);
  }

  Future<void> _handleSaveConversation() async {
    await context.read<ConversationHistoryService>().endSession();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation saved to history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleOpenKeyboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CustomMessageSheet(),
    );
  }

  void _sendToTTS(String message) {
    final messageObj = ChatMessage(
      text: message,
      sender: MessageSender.me,
      time: DateTime.now(),
    );
    context.read<SttService>().addMyMessage(messageObj);
    context.read<ConversationHistoryService>().addMessage(messageObj);
    context.read<TtsService>().speak(message);
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _dragStart = details.globalPosition;
      _dragCurrent = details.globalPosition;
      _isDragging = true;
    });
    _animationController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() => _dragCurrent = details.globalPosition);
  }

  void _handleDragEnd(DragEndDetails details) {
    switch (_activeSegment) {
      case _Segment.yes:
        _sendToTTS('Yes');
        break;
      case _Segment.no:
        _sendToTTS('No');
        break;
      case _Segment.repeat:
        _sendToTTS('Can you repeat what you said again?');
        break;
      case _Segment.cancel:
      case _Segment.none:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cancelled'),
            duration: Duration(milliseconds: 600),
          ),
        );
        break;
    }
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragCurrent = null;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        // clipBehavior none so the gesture circle can visually grow upward
        // past this bar's bounds without getting cut off by the screen edge
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    icon: Icons.bookmark_outline,
                    tooltip: 'Save conversation',
                    onPressed: _handleSaveConversation,
                  ),
                  // reserves the middle space; the circle itself is drawn
                  // separately below so it always paints on top of both
                  // side buttons regardless of how big it scales
                  const SizedBox(width: 70),
                  _buildIconButton(
                    icon: Icons.keyboard,
                    tooltip: 'Custom message',
                    onPressed: _handleOpenKeyboard,
                  ),
                ],
              ),
            ),
            // painted last -> always renders above the save/keyboard buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGestureCircle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        iconSize: 24,
        color: Theme.of(context).textTheme.titleSmall?.color,
      ),
    );
  }

  Widget _buildGestureCircle() {
    final outline = Theme.of(context).colorScheme.outline ?? Colors.grey;
    final tertiaryContainer = Theme.of(context).colorScheme.tertiaryContainer;
    final iconColor = Theme.of(context).textTheme.titleSmall?.color;

    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: SizedBox(
        width: 70,
        height: 70,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              // anchor growth at the bottom so the circle expands upward,
              // away from the screen edge, instead of overflowing past it
              alignment: Alignment.bottomCenter,
              child: _isDragging
                  ? _ExpandedCircle(activeSegment: _activeSegment, outlineColor: outline)
                  : _NormalCircle(
                      tertiaryContainer: tertiaryContainer,
                      outline: outline,
                      iconColor: iconColor,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _NormalCircle extends StatelessWidget {
  final Color? tertiaryContainer;
  final Color? outline;
  final Color? iconColor;
  const _NormalCircle({
    required this.tertiaryContainer,
    required this.outline,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tertiaryContainer,
        border: Border.all(color: outline ?? Colors.grey, width: 2),
      ),
      child: Icon(Icons.add_circle_outline, color: iconColor, size: 28),
    );
  }
}

/// Shown while dragging - highlights the segment that will fire on release.
/// `activeSegment` here is the *exact same* value used by `_handleDragEnd`,
/// so what's highlighted always matches what action actually happens.
class _ExpandedCircle extends StatelessWidget {
  final _Segment activeSegment;
  final Color outlineColor;
  const _ExpandedCircle({required this.activeSegment, required this.outlineColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(70, 70),
          painter: _CircleSegmentPainter(
            activeSegment: activeSegment,
            outlineColor: outlineColor,
          ),
        ),
        _buildLabels(),
      ],
    );
  }

  Widget _buildLabels() {
    Widget label(
      String text, {
      IconData? icon,
      required _Segment segment,
      required Alignment alignment,
    }) {
      final isActive = activeSegment == segment;
      return Align(
        alignment: alignment,
        child: icon != null
            ? Icon(icon, color: Colors.white, size: isActive ? 13 : 10)
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isActive ? 11 : 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
      );
    }

    // alignment values placed along each wedge's central angle, pulled in
    // a bit from the edge (~0.55 of the way out) so labels sit centered
    // within their pie-slice instead of crowding the rim or the center.
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          label('Yes', segment: _Segment.yes, alignment: const Alignment(-0.55, 0)),
          label('?', segment: _Segment.repeat, alignment: const Alignment(0, -0.55)),
          label('No', segment: _Segment.no, alignment: const Alignment(0.55, 0)),
          label(
            '',
            icon: Icons.close_rounded,
            segment: _Segment.cancel,
            alignment: const Alignment(0, 0.55),
          ),
        ],
      ),
    );
  }
}

/// Draws the 4 swipe-direction segments (pie wedges centered on
/// up/right/down/left) and highlights whichever one is active.
/// Segment->color mapping is fixed and matches `_Segment` 1:1 - no separate
/// angle math, so visuals can't drift out of sync with behavior again.
class _CircleSegmentPainter extends CustomPainter {
  final _Segment activeSegment;
  final Color outlineColor;
  _CircleSegmentPainter({required this.activeSegment, required this.outlineColor});

  static const Map<_Segment, Color> _colors = {
    _Segment.yes: Colors.green,
    _Segment.no: Colors.red,
    _Segment.repeat: Colors.orange,
    _Segment.cancel: Colors.blueGrey,
  };

  // startAngle (degrees, 0 = up, clockwise) for each wedge.
  static const Map<_Segment, double> _startAngles = {
    _Segment.repeat: 315, // top
    _Segment.no: 45, // right
    _Segment.cancel: 135, // bottom
    _Segment.yes: 225, // left
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final segment in _startAngles.keys) {
      final isActive = activeSegment == segment;
      final baseColor = _colors[segment]!;
      // fully opaque always - active segment is a brighter tint of the
      // same color instead of inactive ones being faded out
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = isActive
            ? Color.lerp(baseColor, Colors.white, 0.18)!
            : baseColor;
      final startRadians = (_startAngles[segment]! - 90) * math.pi / 180;
      canvas.drawArc(rect, startRadians, math.pi / 2, true, paint);
    }

    final borderPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    for (final angle in [45, 135, 225, 315]) {
      final radians = angle * math.pi / 180;
      final end = Offset(
        center.dx + radius * math.cos(radians),
        center.dy + radius * math.sin(radians),
      );
      canvas.drawLine(center, end, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_CircleSegmentPainter oldDelegate) =>
      oldDelegate.activeSegment != activeSegment ||
      oldDelegate.outlineColor != outlineColor;
}

class _CustomMessageSheet extends StatefulWidget {
  const _CustomMessageSheet();
  @override
  State<_CustomMessageSheet> createState() => _CustomMessageSheetState();
}

class _CustomMessageSheetState extends State<_CustomMessageSheet> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    final messageObj = ChatMessage(
      text: message,
      sender: MessageSender.me,
      time: DateTime.now(),
    );
    context.read<SttService>().addMyMessage(messageObj);
    context.read<ConversationHistoryService>().addMessage(messageObj);
    Navigator.pop(context);
    await context.read<TtsService>().speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Custom Message', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                autofocus: true,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Type your message...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.5),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send, size: 20),
                label: Text(
                  'Send',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
