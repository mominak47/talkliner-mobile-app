import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SignalBarsWidget extends StatelessWidget {
  const SignalBarsWidget({super.key});

  Icon _getSignalIcon(SocketConnectionQuality connectionQuality) {
    switch (connectionQuality) {
      case SocketConnectionQuality.excellent:
        return const Icon(LucideIcons.signalHigh, color: Colors.green);
      case SocketConnectionQuality.good:
        return const Icon(LucideIcons.signal, color: Colors.green);
      case SocketConnectionQuality.fair:
        return const Icon(LucideIcons.signalLow, color: Colors.orange);
      case SocketConnectionQuality.poor:
        return const Icon(LucideIcons.signal, color: Colors.red);
      case SocketConnectionQuality.veryPoor:
        return const Icon(LucideIcons.signalZero, color: Colors.red);
      case SocketConnectionQuality.disconnected:
        return const Icon(LucideIcons.signalZero, color: Colors.red);
    }
  }

  String _getQualityText(SocketConnectionQuality quality) {
    switch (quality) {
      case SocketConnectionQuality.excellent:
        return "Excellent";
      case SocketConnectionQuality.good:
        return "Good";
      case SocketConnectionQuality.fair:
        return "Fair";
      case SocketConnectionQuality.poor:
        return "Poor";
      case SocketConnectionQuality.veryPoor:
        return "Very Poor";
      case SocketConnectionQuality.disconnected:
        return "Disconnected";
    }
  }

  Widget _buildLatencyChart(List<PingItem> pings, bool isDarkMode) {
    if (pings.isEmpty) return const SizedBox();

    // Find min and max latency for scaling
    final latencies = pings.map((p) => p.latency.toDouble()).toList();
    final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
    final minLatency = latencies.reduce((a, b) => a < b ? a : b);

    // Add some padding to the range
    var range = maxLatency - minLatency;

    // Ensure minimum range to avoid zero interval
    if (range < 10) {
      range = 10;
    }

    final yMax = maxLatency + (range * 0.2);
    final yMin =
        (minLatency - (range * 0.2)).clamp(0.0, double.infinity).toDouble();

    // Calculate horizontal interval and ensure it's not zero
    final horizontalInterval =
        ((yMax - yMin) / 4).clamp(1.0, double.infinity).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: horizontalInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < pings.length) {
                    final ping = pings[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('HH:mm:ss').format(ping.time),
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: horizontalInterval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}ms',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
            ),
          ),
          minX: 0,
          maxX: (pings.length - 1).toDouble(),
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots:
                  pings
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.latency.toDouble(),
                        ),
                      )
                      .toList(),
              isCurved: false,
              color: TalklinerThemeColors.primary300,
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 1,
                    color: Colors.blue,
                    strokeWidth: 2,
                    strokeColor: isDarkMode ? Colors.white : Colors.black,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: TalklinerThemeColors.primary300.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final ping = pings[barSpot.x.toInt()];
                  return LineTooltipItem(
                    '${ping.latency}ms\n${DateFormat('HH:mm:ss').format(ping.time)}',
                    TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketController = Get.find<SocketController>();
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

    return Obx(
      () => GestureDetector(
        onTap: () {
          // Show bottom sheet with network information
          Get.bottomSheet(
            DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.3,
              maxChildSize: 1,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? TalklinerThemeColors.gray900
                            : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        width: 60,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Network Information".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Obx(() {
                              final pings = socketController.last10Pings;
                              final currentLatency =
                                  socketController.latency.value;
                              final quality =
                                  socketController.connectionQuality.value;

                              // Calculate average latency
                              final avgLatency =
                                  pings.isEmpty
                                      ? 0.0
                                      : pings
                                              .map((p) => p.latency)
                                              .reduce((a, b) => a + b) /
                                          pings.length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Chart Section
                                  Text(
                                    "Latency History",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Chart
                                  if (pings.isEmpty)
                                    Container(
                                      height: 200,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "No data available yet",
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.white.withOpacity(
                                                    0.5,
                                                  )
                                                  : Colors.black.withOpacity(
                                                    0.5,
                                                  ),
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 200,
                                      child: _buildLatencyChart(
                                        pings,
                                        isDarkMode,
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // Stats Cards Row
                                  Text(
                                    "Current Latency: ${currentLatency.toInt()}ms, Average Latency: ${avgLatency.toInt()}ms, Connection Quality: ${_getQualityText(quality)}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                      color:
                                          isDarkMode
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 8, 0),
                child: _getSignalIcon(socketController.connectionQuality.value),
              ),
              Positioned(
                top: 0,
                left: 4,
                right: 0,
                bottom: 0,
                child: Text(
                  "${socketController.latency.value.toInt().toString()}ms",
                  style: TextStyle(
                    fontSize: 8,
                    color: isDarkMode ? Colors.white : Colors.black,
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
