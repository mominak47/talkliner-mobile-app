import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final Widget? prefixIcon;
  final bool prefixIconIsSvg;
  final double prefixIconHeight;
  final double prefixIconWidth;
  final Color? prefixIconColor;
  final EdgeInsets padding;
  final OutlinedBorder? shape;
  final double? width;
  final double? height;
  final void Function()? onTapDown;
  final void Function()? onTapUp;
  final void Function()? onLongPressStart;
  final void Function()? onLongPressEnd;
  final void Function()? onTapCancel;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textAlign = TextAlign.center,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.textColor = TalklinerThemeColors.gray900,
    this.backgroundColor = TalklinerThemeColors.primary500,
    this.prefixIcon,
    this.prefixIconIsSvg = false,
    this.prefixIconHeight = 20,
    this.prefixIconWidth = 20,
    this.prefixIconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.shape,
    this.width,
    this.height,
    this.onTapDown,
    this.onTapUp,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTapDown: (_) => onTapDown?.call(),
        onTapUp: (_) => onTapUp?.call(),
        onLongPressStart: (_) => onLongPressStart?.call(),
        onLongPressEnd: (_) => onLongPressEnd?.call(),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (prefixIcon != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: prefixIconHeight,
                    width: prefixIconWidth,
                    child:
                        prefixIconIsSvg
                            ? ColorFiltered(
                              colorFilter:
                                  prefixIconColor != null
                                      ? ColorFilter.mode(
                                        prefixIconColor!,
                                        BlendMode.srcIn,
                                      )
                                      : const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.dst,
                                      ),
                              child: prefixIcon!,
                            )
                            : IconTheme(
                              data: IconThemeData(color: prefixIconColor),
                              child: prefixIcon!,
                            ),
                  ),
                ),
              Center(
                child: Text(
                  text,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
