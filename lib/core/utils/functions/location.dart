import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../variables/variables.dart';

class GetLocation {
  Future<void> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();

    if (kDebugMode) {
      print(
        "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}",
      );
    }

    lat = locationData.latitude;
    long = locationData.longitude;
    currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
  }
}
