import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ### Component 3: utility bar
///
/// - is a similer to navigation bar at the bottom of the screan
/// - it contain 2 button at the side and a circle in the midle
/// - the button on the left make that you save the conversation in history
/// - the button on the rigth open the keyboard to write a custom massage
/// - the circle in the middle have a special functonality that is
///     - if you hover it then swipe to the left it output "yes"
///     - if you hover it then swipe to the rigth it output "no"
///     - if you hover it then swipe up it output a "?" and ask to "repeat what he sayed again"
///     - if you hover it then swipe down it cancels the operation
/// - all output got to the seame text-to-speach model

// note: might rewrite the entire page later (not a good implementaiton)

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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
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

  /// this method allow us to save conversation
  void _handleSaveConversation() {
    print('Saving conversation to history');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conversation saved to history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// this method allow us to type cusstom massage using the keyboard
  void _handleOpenKeyboard() {
    print('Opening keyboard for custom message');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomMessageSheet(),
    );
  }

  /// method for sending message
  void _sendToTTS(String message) {
    print('Sending to TTS: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speaking: $message'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Handle drag start
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _dragStart = details.globalPosition;
      _dragCurrent = details.globalPosition;
      _isDragging = true;
    });
    _animationController.forward();
  }

  // Handle drag update
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragCurrent = details.globalPosition;
    });
  }

  // Handle drag end
  void _handleDragEnd(DragEndDetails details) {
    if (_dragStart == null || _dragCurrent == null) {
      _cancelOperation();
      return;
    }
    // calculate the position
    final dx = _dragCurrent!.dx - _dragStart!.dx;
    final dy = _dragCurrent!.dy - _dragStart!.dy;

    // Determine which segment was selected
    final angle = math.atan2(dy, dx);
    final degrees = angle * 180 / math.pi;

    // Convert to 0-360 range
    final normalizedDegrees = (degrees + 360) % 360;

    // circle divide into 4 segments
    // Right (No): 315-45 degrees
    // Top (Repeat): 225-315 degrees
    // Left (Yes): 135-225 degrees
    // Bottom (Cancel): 45-135 degrees

    if ((normalizedDegrees >= 315 || normalizedDegrees < 45)) {
      _sendToTTS('No');
    } else if (normalizedDegrees >= 225 && normalizedDegrees < 315) {
      _sendToTTS('Can you repeat what you said again?');
    } else if (normalizedDegrees >= 135 && normalizedDegrees < 225) {
      _sendToTTS('Yes');
    } else {
      // Bottom segment - Cancel
      print('Operation cancelled'); // well get deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancelled'),
          duration: Duration(milliseconds: 100),
        ),
      );
    }
    // reset state
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragCurrent = null;
    });
    _animationController.reverse();
  }

  void _cancelOperation() {
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragCurrent = null;
    });
    _animationController.reverse();
  }

  // Get active segment based on drag position
  String _getActiveSegment() {
    if (_dragStart == null || _dragCurrent == null) return 'none';

    final dx = _dragCurrent!.dx - _dragStart!.dx;
    final dy = _dragCurrent!.dy - _dragStart!.dy;

    final angle = math.atan2(dy, dx);
    final degrees = angle * 180 / math.pi;
    final normalizedDegrees = (degrees + 270) % 360;

    if ((normalizedDegrees >= 315 || normalizedDegrees < 45)) {
      return 'left'; // Yes
    } else if (normalizedDegrees >= 45 && normalizedDegrees < 135) {
      return 'bottom'; // Cancel
    } else if (normalizedDegrees >= 135 && normalizedDegrees < 225) {
      return 'right'; // No
    } else {
      return 'top'; // Repeat
    }
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(
                icon: Icons.bookmark_outline,
                tooltip: 'Save conversation',
                onPressed: _handleSaveConversation,
              ),
              _buildGestureCircle(),
              _buildIconButton(
                icon: Icons.keyboard,
                tooltip: 'Custom message',
                onPressed: _handleOpenKeyboard,
              ),
            ],
          ),
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
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              child: _isDragging
                  ? _buildExpandedCircle()
                  : _buildNormalCircle(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNormalCircle() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.tertiaryContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.add_circle_outline,
        color: Theme.of(context).textTheme.titleSmall?.color,
        size: 28,
      ),
    );
  }

  Widget _buildExpandedCircle() {
    final activeSegment = _getActiveSegment();

    return Stack(
      children: [
        // Draw the 4 segments
        CustomPaint(
          size: Size(70, 50),
          painter: CircleSegmentPainter(activeSegment: activeSegment),
        ),
        // Add labels
        _buildSegmentLabels(activeSegment),
      ],
    );
  }

  /// Segment labels
  //-- NOTE:
  //    - the icon is not centered
  //    - maybe the icon can be center in a diffrent way
  //    - look up a diffrent method for cordinet
  Widget _buildSegmentLabels(String activeSegment) {
    return Container(
      width: 70,
      height: 50,
      child: Stack(
        children: [
          // Left - YES (Green)
          Positioned(
            left: 5,
            top: 18,
            child: Text(
              'Yes',
              style: TextStyle(
                color: Colors.white,
                fontSize: activeSegment == 'bottom' ? 9 : 7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Top - ? (Orange)
          Positioned(
            left: 30,
            top: 0,
            child: Text(
              ' ? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: activeSegment == 'right' ? 9 : 7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Right - NO (Red)
          Positioned(
            right: 7,
            top: 19,
            child: Text(
              'No',
              style: TextStyle(
                color: Colors.white,
                fontSize: activeSegment == 'top' ? 9 : 7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Bottom - X (Gray)
          Positioned(
            left: 31,
            bottom: 3,
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: activeSegment == 'left' ? 9 : 7,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw the 4 circle segments
class CircleSegmentPainter extends CustomPainter {
  final String activeSegment;

  CircleSegmentPainter({required this.activeSegment});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Define the 4 segments (90 degrees each)
    _drawSegment(
      canvas,
      center,
      radius,
      315,
      90,
      activeSegment == 'right'
          ? Colors.orange
          : Colors.orange.withValues(alpha: 0.6),
    );

    _drawSegment(
      canvas,
      center,
      radius,
      45,
      90,
      activeSegment == 'top' ? Colors.red : Colors.red.withValues(alpha: 0.6),
    );

    _drawSegment(
      canvas,
      center,
      radius,
      135,
      90,
      activeSegment == 'left'
          ? Colors.grey
          : Colors.grey.withValues(alpha: 0.6),
    );

    _drawSegment(
      canvas,
      center,
      radius,
      225,
      90,
      activeSegment == 'bottom'
          ? Colors.green
          : Colors.green.withValues(alpha: 0.6),
    );

    // Draw borders between segments
    final borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, borderPaint);

    // Draw dividing lines for 4 segments
    for (var angle in [45, 135, 225, 315]) {
      final radians = angle * math.pi / 180;
      final end = Offset(
        center.dx + radius * math.cos(radians),
        center.dy + radius * math.sin(radians),
      );
      canvas.drawLine(center, end, borderPaint);
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startRadians = (startAngle - 90) * math.pi / 180;
    final sweepRadians = sweepAngle * math.pi / 180;

    canvas.drawArc(rect, startRadians, sweepRadians, true, paint);
  }

  @override
  bool shouldRepaint(CircleSegmentPainter oldDelegate) {
    return oldDelegate.activeSegment != activeSegment;
  }
}

class _CustomMessageSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 20),
            Text(
              'Custom Message',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 16),
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
                autofocus: true,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Type your message...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Message sent')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(Icons.send, size: 20),
                label: Text(
                  'Send',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
