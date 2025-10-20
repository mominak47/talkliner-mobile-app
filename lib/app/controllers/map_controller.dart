import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapController extends GetxController{
  final RxDouble zoom = 13.0.obs;
  final RxBool isLoading = true.obs;
  final RxList<LatLng> markers = <LatLng>[].obs;

  // Initialize the map
  @override
  void onInit() {
    super.onInit();
    // Initialize the map
    currentLocation();
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