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
  /// callback to notify parent when message is sent
  final Function(String)? onMessageSent;
  const UtilityNavigationBar({super.key, this.onMessageSent});
  @override
  State<UtilityNavigationBar> createState() => _UtilityNavigationBarState();
}

class _UtilityNavigationBarState extends State<UtilityNavigationBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController userMessage = TextEditingController();

  /// starting position of the drag
  Offset? dragStart;

  /// current finger position during drag
  Offset? dragCurrent;

  /// flag that indicate if user is currently dragging
  bool isDragging = false;

  /// controller for animation of expanding circle
  late AnimationController animationController;

  /// scale animation used when the circle expand
  late Animation<double> scaleAnimation;

  /// how much the circle move horizontally when expanded
  static const double expandedOffsetX = 45.0;

  /// how much the circle move vertically when expanded
  static const double expandedOffsetY = -80.0;

  @override
  void initState() {
    super.initState();

    /// initialize animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// define scale animation from normal size -> expanded size
    scaleAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    /// clean up resources
    userMessage.dispose();
    /// dispose animation controller to prevent memory leak
    animationController.dispose();
    super.dispose();
  }
  /// Message Handling 
  /// send user text input to TTS

  void handleSend() {
    final text = userMessage.text.trim();
    /// ignore empty messages
    if (text.isNotEmpty) {
      sendToTTS(text);
      /// notify parent widget if needed
      if (widget.onMessageSent != null) {
        widget.onMessageSent!(text);
      }
      /// reset UI
      userMessage.clear();
      FocusScope.of(context).unfocus();
    }
  }

  /// this method allow us to save conversation
  void handleSaveConversation() {
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
  Widget buildCustomMessageSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      /// style of message container
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),

      /// layout of textfield + send button
      child: Row(
        children: [
          /// text input
          Expanded(
            child: TextField(
              controller: userMessage,
              textAlign: TextAlign.start,
              decoration: const InputDecoration(
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
            onPressed: () {
              setState(() {
                handleSend();
              });
            },
          ),
        ],
      ),
    );
  }

  /// method for sending message to text-to-speech model
  void sendToTTS(String message) {
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
  void handleDragStart(DragStartDetails details) {
    setState(() {
      /// store drag start position
      dragStart = details.globalPosition;

      /// initialize current position
      dragCurrent = details.globalPosition;

      /// activate dragging mode
      isDragging = true;
    });

    /// start expand animation
    animationController.forward();
  }

  /// Handle drag update
  void handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      /// update finger position during drag
      dragCurrent = details.globalPosition;
    });
  }

  /// Handle drag end
  void handleDragEnd(DragEndDetails details) {
    /// if drag positions are not valid cancel operation
    if (dragStart == null || dragCurrent == null) {
      cancelOperation();
      return;
    }

    /// determine which segment user selected
    final active = getActiveSegment();

    if (active == 'right') {
      sendToTTS('No');
    } else if (active == 'top') {
      sendToTTS('Can you repeat what you said again?');
    } else if (active == 'left') {
      sendToTTS('Yes');
    } else if (active == 'bottom') {
      print('Operation cancelled');
    }

    /// reset UI
    cancelOperation();
  }

  /// reset drag state and reverse animation
  void cancelOperation() {
    setState(() {
      isDragging = false;
      dragStart = null;
      dragCurrent = null;
    });
    animationController.reverse();
  }

  /// determine which direction the user dragged
  String getActiveSegment() {
    if (dragStart == null || dragCurrent == null) return 'none';

    /// calculate difference between start and current
    final dx = dragCurrent!.dx - dragStart!.dx;
    final dy = dragCurrent!.dy - dragStart!.dy;

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
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            /// layout of circle + message field
            child: Row(
              children: [
                /// circle + save button column
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildGestureCircle(),
                    const SizedBox(height: 8),

                    /// save conversation button
                    buildIconButton(
                      icon: Icons.bookmark_outline,
                      tooltip: 'Save conversation',
                      onPressed: handleSaveConversation,
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                /// custom message field
                Expanded(child: buildCustomMessageSheet()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// reusable circular icon button
  Widget buildIconButton({
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
  Widget buildGestureCircle() {
    return GestureDetector(
      /// drag events
      onPanStart: handleDragStart,
      onPanUpdate: handleDragUpdate,
      onPanEnd: handleDragEnd,

      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          /// normal circle when not dragging
          if (!isDragging) {
            return SizedBox(width: 45, height: 45, child: buildNormalCircle());
          }

          /// expanded circle when dragging
          return Transform.translate(
            offset: const Offset(expandedOffsetX, expandedOffsetY),

            child: Transform.scale(
              scale: scaleAnimation.value,

              child: SizedBox(
                width: 45,
                height: 45,
                child: buildExpandedCircle(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// default circle appearance
  Widget buildNormalCircle() {
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
  Widget buildExpandedCircle() {
    /// get current active segment
    final activeSegment = getActiveSegment();

    return Stack(
      children: [
        /// colored circle slices
        CustomPaint(
          size: const Size(45, 45),
          painter: CircleSegmentPainter(activeSegment: activeSegment),
        ),

        /// labels inside segments
        buildSegmentLabels(activeSegment),
      ],
    );
  }

  /// build labels for each direction
  Widget buildSegmentLabels(String activeSegment) {
    return Stack(
      children: [
        buildCenteredLabel(Alignment.topCenter, '?', activeSegment == 'top'),
        buildCenteredLabel(
          Alignment.centerRight,
          'No',
          activeSegment == 'right',
        ),
        buildCenteredLabel(
          Alignment.centerLeft,
          'Yes',
          activeSegment == 'left',
        ),
        buildCenteredLabel(
          Alignment.bottomCenter,
          'X',
          activeSegment == 'bottom',
          isIcon: true,
        ),
      ],
    );
  }

  /// reusable label builder
  Widget buildCenteredLabel(
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
          ? Icon(Icons.close, color: Colors.white, size: isActive ? 8 : 6)
          : Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isActive ? 8 : 6,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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

    final rect = Rect.fromCircle(center: center, radius: radius);

    /// helper function to draw one slice
    void drawSlice(double startAngle, Color color, bool isActive) {
      final paint = Paint()
        ..color = isActive ? color : color.withOpacity(0.6)
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
  bool shouldRepaint(CircleSegmentPainter oldDelegate) =>
      oldDelegate.activeSegment != activeSegment;
}
