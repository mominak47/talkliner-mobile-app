import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class CircleButton extends StatefulWidget {
  final double circleSize;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final String text;
  final TextStyle textStyle;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Color borderColor;
  final Widget? customIcon;
  final VoidCallback? onTapCancel;

  const CircleButton({
    super.key,
    this.circleSize = 315,
    this.backgroundColor = TalklinerThemeColors.gray020,
    this.iconColor = TalklinerThemeColors.gray080,
    this.iconSize = 80,
    this.text = "Type Text",
    this.textStyle = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: TalklinerThemeColors.gray800,
    ),
    this.customIcon,
    this.onTapDown,
    this.onTapUp,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.borderWidth = 0,
    this.boxShadow,
    this.borderColor = TalklinerThemeColors.gray020,
    this.onTapCancel,
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTapCancel: () => widget.onTapCancel?.call(),
      onTapDown: (_) => widget.onTapDown?.call(),
      onTapUp: (_) => widget.onTapUp?.call(),
      onLongPressStart: (_) => widget.onLongPressStart?.call(),
      onLongPressEnd: (_) => widget.onLongPressEnd?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: widget.circleSize,
        height: widget.circleSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor, width: 20),
          boxShadow: widget.boxShadow,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(
                  widget.text,
                  style: widget.textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Center(
              child:
                  widget.customIcon ??
                  Icon(
                    Icons.mic,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
