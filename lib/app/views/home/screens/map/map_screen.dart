import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:talkliner/app/controllers/map_controller.dart' as mapController2;
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final mapController = Get.find<mapController2.MapController>();

    // Add a marker to the map
    mapController.addMarker(LatLng(37.774929, -122.419416));

    return FlutterMap(
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: mapController.getMarkers().map((marker) => Marker(
            point: marker,
            child: Icon(Icons.location_on, color: TalklinerThemeColors.primary500, size: 60),
          )).toList(),
        ),
      ],
    );
  }
}