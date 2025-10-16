import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/circle_button.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/custom_elevated_button.dart';

enum PushToTalkButtonState {
  notSelected,
  inactive,
  active,
  busy,
  disabled,
  connectingRoom,
}

enum PushToTalkButtonType { main, bar }

class PushToTalkButton extends StatelessWidget {
  PushToTalkButton({
    super.key,
    required this.buttonText,
    required this.isDarkMode,
    required this.onTapDown,
    required this.onTapUp,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onTapCancel,
    required this.state,
    required this.type,
    required this.doWeNeedBorder,
    required this.doWeNeedShadows,
  });

  final bool doWeNeedShadows;
  final bool doWeNeedBorder;

  final String buttonText;
  final bool isDarkMode;
  final Function() onTapDown;
  final Function() onTapUp;
  final Function() onLongPressStart;
  final Function() onLongPressEnd;
  final Function() onTapCancel;

  final Color buttonBackgroundColor = Colors.black;
  final double buttonSize = 315;
  final Color buttonIconColor = Colors.white;
  final double buttonIconSize = 80;
  final TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final PushToTalkButtonState state;
  final PushToTalkButtonType type;
  // The previous code attempted to assign to final fields, which is not allowed.
  // Instead, use local variables to determine button appearance based on state.

  Color get _buttonBackgroundColor {
    switch (state) {
      case PushToTalkButtonState.notSelected:
        return isDarkMode ? TalklinerThemeColors.gray700 : TalklinerThemeColors.gray030;
      case PushToTalkButtonState.inactive:
        return TalklinerThemeColors.primary025;
      case PushToTalkButtonState.active:
        return TalklinerThemeColors.primary500;
      case PushToTalkButtonState.busy:
        return TalklinerThemeColors.primary025;
      case PushToTalkButtonState.disabled:
        return TalklinerThemeColors.gray030;
      case PushToTalkButtonState.connectingRoom:
        return TalklinerThemeColors.gray030;
    }
  }

  String get _buttonText {
    switch (state) {
      case PushToTalkButtonState.notSelected:
        return "no_selection".tr;
      case PushToTalkButtonState.inactive:
        return "push_to_talk".tr;
      case PushToTalkButtonState.active:
        return "speak".tr;
      case PushToTalkButtonState.busy:
        return buttonText;
      case PushToTalkButtonState.disabled:
        return "ptt_disabled".tr;
      case PushToTalkButtonState.connectingRoom:
        return "connecting".tr;
    }
  }

  double get _buttonSize {
    switch (state) {
      case PushToTalkButtonState.active:
        return 300;
      case PushToTalkButtonState.busy:
        return 300;
      default:
        return 315;
    }
  }

  Color get _buttonIconColor {
    switch (state) {
      case PushToTalkButtonState.notSelected:
        return TalklinerThemeColors.gray080;
      case PushToTalkButtonState.inactive:
        return TalklinerThemeColors.primaryMain;
      case PushToTalkButtonState.active:
        return Colors.white;
      case PushToTalkButtonState.busy:
        return TalklinerThemeColors.primaryMain;
      case PushToTalkButtonState.disabled:
        return TalklinerThemeColors.gray080;
      case PushToTalkButtonState.connectingRoom:
        return TalklinerThemeColors.gray080;
    }
  }

  double get _buttonIconSize {
    switch (state) {
      default:
        return buttonIconSize;
    }
  }

  TextStyle get _buttonTextStyle {
    switch (state) {
      case PushToTalkButtonState.notSelected:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TalklinerThemeColors.gray080,
        );
      case PushToTalkButtonState.inactive:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TalklinerThemeColors.gray900,
        );
      case PushToTalkButtonState.active:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
      case PushToTalkButtonState.busy:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TalklinerThemeColors.gray900,
        );
      case PushToTalkButtonState.disabled:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TalklinerThemeColors.gray080,
        );
      case PushToTalkButtonState.connectingRoom:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TalklinerThemeColors.gray080,
        );
    }
  }

  dynamic get _buttonCustomIcon {
    switch (state) {
      case PushToTalkButtonState.active:
        return SvgPicture.asset('assets/images/ptt_wave_white.svg', width: 80, height: 80);
      case PushToTalkButtonState.inactive:
        return Icon(LucideIcons.mic, color: TalklinerThemeColors.primaryMain, size: 60);
      case PushToTalkButtonState.busy:
        return SvgPicture.asset('assets/images/ptt_wave_primary.svg', width: 80, height: 80);
      case PushToTalkButtonState.disabled:
        return SvgPicture.asset('assets/images/ptt_disabled.svg', width: 80, height: 80);
      case PushToTalkButtonState.connectingRoom:
        return Icon(LucideIcons.volumeX, color: TalklinerThemeColors.gray050, size: 80);
      default:
        return null;
    }
  }

  List<BoxShadow> get _buttonBoxShadow {
    if(!doWeNeedShadows){
      return [];
    }
    switch (state) {
      case PushToTalkButtonState.active:
        return [
          BoxShadow(
            color: TalklinerThemeColors.primary500.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 5,
          ),
        ];
      case PushToTalkButtonState.inactive:
        return [
          BoxShadow(
            color: TalklinerThemeColors.primary500.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: Offset(0, 0),
            spreadRadius: 10,
          ),
        ];
      case PushToTalkButtonState.connectingRoom:
        return [];
      default:
        return [];
    }
  }

  Color get _buttonBorderColor {
    if(!doWeNeedBorder){
      return Colors.transparent;
    }
    switch (state) {
      case PushToTalkButtonState.notSelected:
        return TalklinerThemeColors.gray080.withValues(alpha: 0.1);
      case PushToTalkButtonState.active:
        return TalklinerThemeColors.primary800;
      case PushToTalkButtonState.inactive:
        return TalklinerThemeColors.primary500.withValues(alpha: 0.4);
      case PushToTalkButtonState.connectingRoom:
        return Colors.transparent;
      case PushToTalkButtonState.disabled:
        return TalklinerThemeColors.gray080.withValues(alpha: 0.1);
      case PushToTalkButtonState.busy:
        return TalklinerThemeColors.primary500.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (type == PushToTalkButtonType.bar) {
      return CustomElevatedButton(
        text: _buttonText,
        fontWeight: FontWeight.w600,
        prefixIconIsSvg: true,
        prefixIcon: Icon(LucideIcons.mic, color: TalklinerThemeColors.gray050, size: 24),
        prefixIconHeight: 24,
        prefixIconColor: _buttonIconColor,
        textColor: _buttonTextStyle.color!,
        backgroundColor: _buttonBackgroundColor,
        height: 60,
        // Events
        onTapDown: onTapDown, // Start transmission on press
        onTapUp: onTapUp, // Stop transmission on release
        onLongPressStart: onLongPressStart, // Handle long press start
        onLongPressEnd: onLongPressEnd, // Handle long press end
        onTapCancel: onTapCancel, // Handle tap cancel
      );
    }
    return CircleButton(
      backgroundColor: _buttonBackgroundColor,
      text: _buttonText,
      circleSize: _buttonSize,
      iconColor: _buttonIconColor,
      iconSize: _buttonIconSize,
      textStyle: _buttonTextStyle,
      customIcon: _buttonCustomIcon,
      boxShadow: _buttonBoxShadow,
      borderColor: _buttonBorderColor,
      // Events
      onTapDown: onTapDown, // Start transmission on press
      onTapUp: onTapUp, // Stop transmission on release
      onLongPressStart: onLongPressStart, // Handle long press start
      onLongPressEnd: onLongPressEnd, // Handle long press end
      onTapCancel: onTapCancel, // Handle tap cancel
    );
  }
}
