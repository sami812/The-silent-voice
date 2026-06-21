import 'package:flutter/material.dart';

/// The 3 states the camera can be in on the sign-language page.
enum CameraMode { front, back, off }

/// ### Sign-language page utility bar
///
/// - left: save conversation
/// - center: toggle whether the app is actively translating via the camera
/// - right: expanding picker for camera mode (front / back / off)
///
/// The camera-mode picker uses Flutter's Overlay system (not a local
/// Stack/Positioned) - a locally-nested popup visually paints above
/// sibling widgets fine, but touch hit-testing in Flutter follows the
/// widget tree's own layout regions, not paint order. Since this bar
/// sits in a Column below the subtitle window, a popup that visually
/// overflows upward into that sibling's screen area would never actually
/// receive taps there - the sibling intercepts the touch first. Overlay
/// inserts the popup at the app's root level instead, where it gets
/// correct hit-testing regardless of what's visually underneath.
class CvUtilityBar extends StatefulWidget {
  final VoidCallback onSave;
  final bool isTranslating;
  final ValueChanged<bool> onToggleTranslating;
  final CameraMode cameraMode;
  final ValueChanged<CameraMode> onCameraModeChanged;

  const CvUtilityBar({
    super.key,
    required this.onSave,
    required this.isTranslating,
    required this.onToggleTranslating,
    required this.cameraMode,
    required this.onCameraModeChanged,
  });

  @override
  State<CvUtilityBar> createState() => _CvUtilityBarState();
}

class _CvUtilityBarState extends State<CvUtilityBar> {
  final GlobalKey _cameraButtonKey = GlobalKey();
  OverlayEntry? _menuEntry;

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  void _removeMenu() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _toggleExpanded() {
    if (_menuEntry != null) {
      _removeMenu();
    } else {
      _showMenu();
    }
  }

  void _showMenu() {
    final renderBox = _cameraButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    // approximate height of the 3-option column (3 x 44px circles + their
    // vertical padding) so the menu sits just above the button.
    const menuHeight = 172.0;
    const menuWidth = 52.0;

    _menuEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // full-screen transparent layer - tapping anywhere outside the
            // menu dismisses it
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeMenu,
              ),
            ),
            Positioned(
              left: buttonPosition.dx + (buttonSize.width - menuWidth) / 2,
              top: buttonPosition.dy - menuHeight - 8,
              child: _buildExpandedOptions(context),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_menuEntry!);
  }

  void _selectMode(CameraMode mode) {
    widget.onCameraModeChanged(mode);
    _removeMenu();
  }

  IconData _iconForMode(CameraMode mode) {
    switch (mode) {
      case CameraMode.front:
        return Icons.camera_front_outlined;
      case CameraMode.back:
        return Icons.camera_rear_outlined;
      case CameraMode.off:
        return Icons.videocam_off_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        border: Border(top: BorderSide(color: outline, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _circleIconButton(
                icon: Icons.bookmark_outline,
                tooltip: 'Save conversation',
                onPressed: widget.onSave,
              ),
              _buildTranslateToggle(context),
              _circleIconButton(
                key: _cameraButtonKey,
                icon: _iconForMode(widget.cameraMode),
                tooltip: 'Camera',
                onPressed: _toggleExpanded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
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

  Widget _buildTranslateToggle(BuildContext context) {
    final isOn = widget.isTranslating;
    const activeColor = Color(0xFF1067FC);
    return GestureDetector(
      onTap: () => widget.onToggleTranslating(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isOn ? activeColor : Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOn ? Icons.sign_language_rounded : Icons.sign_language_outlined,
              color: isOn ? Colors.white : Theme.of(context).textTheme.titleSmall?.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isOn ? 'Translating' : 'Paused',
              style: TextStyle(
                color: isOn ? Colors.white : Theme.of(context).textTheme.titleSmall?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedOptions(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    const activeColor = Color(0xFF1067FC);

    Widget option(CameraMode mode, IconData icon, String tooltip) {
      final isSelected = widget.cameraMode == mode;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: GestureDetector(
          onTap: () => _selectMode(mode),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Theme.of(context).colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: outline, width: 1),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.titleSmall?.color,
              size: 20,
            ),
          ),
        ),
      );
    }

    return Material(
      // Material + transparent color so the popup's shadow/border render
      // correctly when placed directly in the Overlay (which doesn't
      // provide an ambient Material like normal widget tree does).
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(CameraMode.front, Icons.camera_front_outlined, 'Front camera'),
            option(CameraMode.back, Icons.camera_rear_outlined, 'Back camera'),
            option(CameraMode.off, Icons.videocam_off_outlined, 'Camera off'),
          ],
        ),
      ),
    );
  }
}
