import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<LatLng> getCurrentLocation() async {
    // Stubbed for demo; plug in location package for real GPS.
    return const LatLng(18.673, 78.099);
  }
}

