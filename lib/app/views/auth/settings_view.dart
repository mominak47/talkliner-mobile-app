import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:talkliner/app/controllers/app_settings_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppSettingsController appSettingsController = Get.find<AppSettingsController>();
    final TextEditingController apiUrlController = TextEditingController(text: appSettingsController.apiUrl.value);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("API URL"),
              TextField(
                controller: apiUrlController,
                onEditingComplete: () => appSettingsController.setApiUrl(apiUrlController.text),
                decoration: InputDecoration(
                  prefixIcon: Icon(LucideIcons.link2),
                  hintText: 'https://example.com/api',
                  suffixIcon: IconButton(
                    onPressed: () {
                      Get.bottomSheet(
                        DraggableScrollableSheet(
                          initialChildSize:
                              0.8, // 80% of screen height initially
                          minChildSize: 0.3, // Minimum 30% when dragged down
                          maxChildSize: 0.95, // Maximum 95% when dragged up
                          builder: (context, scrollController) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
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
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
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
                                          "Scan QR Code",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  QRCodeDartScanView(
                                    typeScan: TypeScan.live,
                                    onCapture: (Result result) async {
                                      try {
                                        debugPrint(result.text);
                                        apiUrlController.text = result.text;
                                        appSettingsController.setApiUrl(result.text);
                                        Get.back();

                                        // Show toast
                                        Fluttertoast.showToast(
                                          msg: 'Server Added'.tr,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          fontSize: 16.0,
                                        );

                                        // Vibrate
                                        HapticFeedback.heavyImpact();

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
                    icon: Icon(LucideIcons.qrCode),
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
