import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

enum MapType { standard, cyclosm, cycle, transport, tracestrack, humanitarian }

class MapController extends GetxController {
  final RxDouble zoom = 13.0.obs;
  final RxBool isLoading = true.obs;
  final RxList<LatLng> markers = <LatLng>[].obs;
  final Rx<MapType> currentMapType = MapType.standard.obs;
  final RxDouble currentHeading = 0.0.obs;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Initialize the map
  @override
  void onInit() {
    super.onInit();
    // Initialize the map
    currentLocation();

    _compassSubscription = FlutterCompass.events?.listen((event) {
      currentHeading.value = event.heading ?? 0.0;
    });
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    super.onClose();
  }

  void setMapType(MapType type) {
    currentMapType.value = type;
  }

  String getTileUrl(MapType type) {
    switch (type) {
      case MapType.standard:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapType.cyclosm:
        return 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png';
      case MapType.cycle:
        return 'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=755063d1cb2f462582a2f73ea38e3e34';
      case MapType.transport:
        return 'https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=755063d1cb2f462582a2f73ea38e3e34';
      case MapType.tracestrack:
        return 'https://tile.tracestrack.com/_/{z}/{x}/{y}.webp?key=a9c975df3a89c8e068a13d0c6c7a0c9f';
      case MapType.humanitarian:
        return 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
    }
  }

  void currentLocation() {
    // Get the current location
    // final location = await Geolocator.getCurrentPosition();
    // addMarker(LatLng(location.latitude, location.longitude));
  }

  void setZoom(double zoom) {
    this.zoom.value = zoom;
  }

  void addMarker(LatLng latLng) {
    markers.add(latLng);
  }

  void removeMarker(LatLng latLng) {
    markers.remove(latLng);
  }

  void clearMarkers() {
    markers.clear();
  }

  List<LatLng> getMarkers() {
    return markers.toList();
  }

  double getZoom() {
    return zoom.value;
  }
}
