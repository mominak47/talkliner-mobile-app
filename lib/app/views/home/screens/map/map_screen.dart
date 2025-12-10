import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/controllers/map_controller.dart'
    as mapController2;
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController flutterMapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some parameters for the animation
    final latTween = Tween<double>(
      begin: flutterMapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: flutterMapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: flutterMapController.camera.zoom,
      end: destZoom,
    );

    _animationController?.dispose();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final controller = _animationController!;

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      flutterMapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        // We don't need to dispose here if we dispose in new call or dispose(),
        // but it's good practice to clean up if simple one-off.
        // However, if we dispose here, _animationController field might point to disposed object.
        // Better to just let it stay until next move or screen dispose.
        // Or set _animationController = null?
        // Let's simpler: Just dispose in dispose() and when creating new one.
      }
    });

    controller.forward();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    LatLng newLocation = LatLng(position.latitude, position.longitude);

    // Update map view
    _animatedMapMove(newLocation, 15.0);

    // Update marker
    final mapController = Get.find<mapController2.MapController>();
    mapController.clearMarkers();
    mapController.addMarker(newLocation);
  }

  @override
  Widget build(BuildContext context) {
    final mapController = Get.find<mapController2.MapController>();
    final callController = Get.find<CallController>();

    // Add a marker to the map <- Removed hardcoded marker logic from here

    Widget showMapControls() {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Positioned(
        right: 10,
        bottom: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            FloatingActionButton(
              heroTag: 'map_zoom_in',
              onPressed: () {
                _animatedMapMove(
                  flutterMapController.camera.center,
                  flutterMapController.camera.zoom + 1,
                );
              },
              backgroundColor:
                  isDarkMode ? TalklinerThemeColors.gray700 : Colors.white,
              shape: CircleBorder(),
              child: Icon(
                LucideIcons.plus,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            FloatingActionButton(
              heroTag: 'map_zoom_out',
              onPressed: () {
                _animatedMapMove(
                  flutterMapController.camera.center,
                  flutterMapController.camera.zoom - 1,
                );
              },
              backgroundColor:
                  isDarkMode ? TalklinerThemeColors.gray700 : Colors.white,
              shape: CircleBorder(),
              child: Icon(
                LucideIcons.minus,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 30),
            FloatingActionButton(
              heroTag: 'map_layers',
              onPressed: () {},
              backgroundColor:
                  isDarkMode ? TalklinerThemeColors.gray700 : Colors.white,
              shape: CircleBorder(),
              child: Icon(
                LucideIcons.layers,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            FloatingActionButton(
              heroTag: 'map_nav',
              onPressed: _getCurrentLocation,
              backgroundColor:
                  isDarkMode ? TalklinerThemeColors.gray700 : Colors.white,
              shape: CircleBorder(),
              child: Icon(
                LucideIcons.navigation2,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: flutterMapController,
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            Obx(
              () => MarkerLayer(
                markers:
                    mapController
                        .getMarkers()
                        .map(
                          (marker) => Marker(
                            point: marker,
                            child: Icon(
                              Icons.location_on,
                              color: TalklinerThemeColors.primary500,
                              size: 60,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            showMapControls(),
            Obx(
              () => Positioned(
                top: 0,
                right: 0,
                left: 0,
                child:
                    callController.activeCall.value != null
                        ? callController.getCallInProgressWidget()
                        : SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
