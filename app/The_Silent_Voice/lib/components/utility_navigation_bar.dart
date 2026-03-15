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

class UtilityNavigationBar extends StatefulWidget {
  const UtilityNavigationBar({super.key});

  @override
  State<UtilityNavigationBar> createState() => _UtilityNavigationBarState();
}

class _UtilityNavigationBarState extends State<UtilityNavigationBar>
    with SingleTickerProviderStateMixin {

  /// starting position of the drag
  Offset? _dragStart;

  /// current finger position during drag
  Offset? _dragCurrent;

  /// flag that indicate if user is currently dragging
  bool _isDragging = false;

  /// controller for animation of expanding circle
  late AnimationController _animationController;

  /// scale animation used when the circle expand
  late Animation<double> _scaleAnimation;

  /// how much the circle move horizontally when expanded
  static const double _expandedOffsetX = 45.0;

  /// how much the circle move vertically when expanded
  static const double _expandedOffsetY = -80.0;

  @override
  void initState() {
    super.initState();

    /// initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// define scale animation from normal size -> expanded size
    _scaleAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    /// dispose animation controller to prevent memory leak
    _animationController.dispose();
    super.dispose();
  }

  /// this method allow us to save conversation
  void _handleSaveConversation() {
    print('Saving conversation to history');

    /// show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation saved to history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// this method builds the custom message input field
  Widget _buildCustomMessageSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      /// style of message container
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),

      /// layout of textfield + send button
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: "Enter message...",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),

          /// send button
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            iconSize: 20,
            icon: const Icon(Icons.send),

            /// send message to text-to-speech
            onPressed: () => _sendToTTS("custom message"),
          ),
        ],
      ),
    );
  }

  /// method for sending message to text-to-speech model
  void _sendToTTS(String message) {
    print('Sending to TTS: $message');

    /// feedback for user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speaking: $message'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Handle drag start
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      /// store drag start position
      _dragStart = details.globalPosition;

      /// initialize current position
      _dragCurrent = details.globalPosition;

      /// activate dragging mode
      _isDragging = true;
    });

    /// start expand animation
    _animationController.forward();
  }

  /// Handle drag update
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      /// update finger position during drag
      _dragCurrent = details.globalPosition;
    });
  }

  /// Handle drag end
  void _handleDragEnd(DragEndDetails details) {

    /// if drag positions are not valid cancel operation
    if (_dragStart == null || _dragCurrent == null) {
      _cancelOperation();
      return;
    }

    /// determine which segment user selected
    final active = _getActiveSegment();

    if (active == 'right') {
      _sendToTTS('No');
    } else if (active == 'top') {
      _sendToTTS('Can you repeat what you said again?');
    } else if (active == 'left') {
      _sendToTTS('Yes');
    } else if (active == 'bottom') {
      print('Operation cancelled');
    }

    /// reset UI
    _cancelOperation();
  }

  /// reset drag state and reverse animation
  void _cancelOperation() {
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragCurrent = null;
    });

    _animationController.reverse();
  }

  /// determine which direction the user dragged
  String _getActiveSegment() {

    if (_dragStart == null || _dragCurrent == null) return 'none';

    /// calculate difference between start and current
    final dx = _dragCurrent!.dx - _dragStart!.dx;
    final dy = _dragCurrent!.dy - _dragStart!.dy;

    /// ignore very small drag movements
    if ((dx.abs() + dy.abs()) < 10) return 'none';

    /// convert drag vector to angle
    final angle = math.atan2(dy, dx);

    /// convert radians to degrees
    final degrees = (angle * 180 / math.pi + 360) % 360;

    /// determine segment based on angle
    if (degrees >= 315 || degrees < 45) return 'right';  
    if (degrees >= 45 && degrees < 135) return 'bottom'; 
    if (degrees >= 135 && degrees < 225) return 'left';  
    if (degrees >= 225 && degrees < 315) return 'top';   

    return 'none';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(

      /// move the bar up when keyboard appear
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(

        /// background of the navigation bar
        decoration: BoxDecoration(
          color: Theme.of(context)
              .bottomNavigationBarTheme
              .backgroundColor,

          /// top border
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            /// layout of circle + message field
            child: Row(
              children: [

                /// circle + save button column
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGestureCircle(),
                    const SizedBox(height: 8),

                    /// save conversation button
                    _buildIconButton(
                      icon: Icons.bookmark_outline,
                      tooltip: 'Save conversation',
                      onPressed: _handleSaveConversation,
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                /// custom message field
                Expanded(
                  child: _buildCustomMessageSheet(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// reusable circular icon button
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(

      /// circular style
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
        iconSize: 22,
        color: Theme.of(context).textTheme.titleSmall?.color,
      ),
    );
  }

  /// main gesture circle widget
  Widget _buildGestureCircle() {
    return GestureDetector(

      /// drag events
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,

      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {

          /// normal circle when not dragging
          if (!_isDragging) {
            return SizedBox(
              width: 45,
              height: 45,
              child: _buildNormalCircle(),
            );
          }

          /// expanded circle when dragging
          return Transform.translate(
            offset: const Offset(
              _expandedOffsetX,
              _expandedOffsetY,
            ),

            child: Transform.scale(
              scale: _scaleAnimation.value,

              child: SizedBox(
                width: 45,
                height: 45,
                child: _buildExpandedCircle(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// default circle appearance
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
        size: 24,
      ),
    );
  }

  /// expanded circle that contains gesture segments
  Widget _buildExpandedCircle() {

    /// get current active segment
    final activeSegment = _getActiveSegment();

    return Stack(
      children: [

        /// colored circle slices
        CustomPaint(
          size: const Size(45, 45),
          painter: CircleSegmentPainter(
            activeSegment: activeSegment,
          ),
        ),

        /// labels inside segments
        _buildSegmentLabels(activeSegment),
      ],
    );
  }

  /// build labels for each direction
  Widget _buildSegmentLabels(String activeSegment) {
    return Stack(
      children: [
        _buildCenteredLabel(
            Alignment.topCenter, '?', activeSegment == 'top'),
        _buildCenteredLabel(
            Alignment.centerRight, 'N', activeSegment == 'right'),
        _buildCenteredLabel(
            Alignment.centerLeft, 'Y', activeSegment == 'left'),
        _buildCenteredLabel(
            Alignment.bottomCenter, 'X', activeSegment == 'bottom',
            isIcon: true),
      ],
    );
  }

  /// reusable label builder
  Widget _buildCenteredLabel(
    Alignment alignment,
    String label,
    bool isActive, {
    bool isIcon = false,
  }) {

    /// move labels slightly toward center
    final targetAlignment = alignment * 0.7;

    return Align(
      alignment: targetAlignment,

      child: isIcon
          ? Icon(
              Icons.close,
              color: Colors.white,
              size: isActive ? 8 : 6,
            )
          : Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isActive ? 8 : 6,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
    );
  }
}

/// painter that draw the circle divided into 4 gesture segments
class CircleSegmentPainter extends CustomPainter {

  /// currently active segment
  final String activeSegment;

  CircleSegmentPainter({required this.activeSegment});

  @override
  void paint(Canvas canvas, Size size) {

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    /// helper function to draw one slice
    void drawSlice(double startAngle, Color color, bool isActive) {

      final paint = Paint()
        ..color = isActive
            ? color
            : color.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect,
        (startAngle - 90) * math.pi / 180,
        90 * math.pi / 180,
        true,
        paint,
      );
    }

    /// draw 4 segments
    drawSlice(315, Colors.orange, activeSegment == 'top');
    drawSlice(45, Colors.red, activeSegment == 'right');
    drawSlice(135, Colors.grey, activeSegment == 'bottom');
    drawSlice(225, Colors.green, activeSegment == 'left');

    /// outer border
    final borderPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(
      CircleSegmentPainter oldDelegate) =>
      oldDelegate.activeSegment != activeSegment;
}