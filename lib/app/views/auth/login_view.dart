import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() {
    return _LoginViewState();
  }
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();

  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final String currentYear = DateTime.now().year.toString();
  bool _obscurePassword = true;



  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _processQrCode(String token) => authController.loginWithToken(token);

  void _handleLogin() => authController.login(_usernameController.text, _passwordController.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Logo
                      Center(
                        child: Theme.of(context).brightness == Brightness.dark 
                          ? SvgPicture.asset(
                              'assets/logos/white_logo.svg',
                              height: 50,
                            ) 
                          : SvgPicture.asset(
                              'assets/logos/talkliner.svg',
                              height: 50,
                            )
                      ),
                      const SizedBox(height: 40),
                      if (authController.error.value != null)
                        Text(
                          authController.error.value ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Username field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'username'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(LucideIcons.user),
                              hintText: 'username_placeholder'.tr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'password'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'password_placeholder'.tr,
                              prefixIcon: const Icon(LucideIcons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Scan QR Code button
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            _handleLogin();
                          } else {
                            // Show error message or handle empty fields
                            Fluttertoast.showToast(
                              msg: 'Please fill in all fields',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              authController.isLoading.value
                                  ? TalklinerThemeColors.primary100
                                  : TalklinerThemeColors.primaryMain,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          authController.isLoading.value
                              ? 'connecting'.tr
                              : 'connect'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                authController.isLoading.value
                                    ? TalklinerThemeColors.gray200
                                    : TalklinerThemeColors.gray900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            // First button - takes exactly half the available width
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {
                                  Get.bottomSheet(
                                    DraggableScrollableSheet(
                                      initialChildSize:
                                          0.8, // 80% of screen height initially
                                      minChildSize:
                                          0.3, // Minimum 30% when dragged down
                                      maxChildSize:
                                          0.95, // Maximum 95% when dragged up
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark 
                                              ? TalklinerThemeColors.gray900 
                                              : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              // Handle bar
                                              Container(
                                                width: 40,
                                                height: 4,
                                                margin: EdgeInsets.symmetric(
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "QR Login",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              QRCodeDartScanView(
                                                typeScan: TypeScan.live,
                                                onCapture: (
                                                  Result result,
                                                ) async {
                                                  try {
                                                    Map<String, dynamic>
                                                    response = jsonDecode(
                                                      result.text,
                                                    );
                                                    if (response['user_token'] !=
                                                        null) {
                                                      _processQrCode(
                                                        response['user_token'],
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg: 'Invalid QR code',
                                                      );
                                                    }
                                                  } catch (e) {
                                                    Fluttertoast.showToast(
                                                      msg: 'Invalid QR code',
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? TalklinerThemeColors.gray800
                                    : Colors.grey[100],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.qrCode,
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'qr_login'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16), // Space between buttons
                            // Second button - takes exactly half the available width
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () => Get.toNamed(Routes.settings),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? TalklinerThemeColors.gray800
                                    : Colors.grey[100],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.settings,
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'settings'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Copyright text
                      Center(
                        child: Text(
                          // Translate the text
                          "Copyright © %s Talkliner".trArgs([currentYear.toString()]),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
