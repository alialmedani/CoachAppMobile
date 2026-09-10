import 'package:latlong2/latlong.dart';

DateTime? lastPressed;

int totalResultCount = 0;
int totalResultCountSlider = 0;
double? lat;
double? long;
LatLng? currentLocation;
List<Map<String, String>> elements = [
  {"code": "IQ", "name": "Iraq", "dial_code": "+964"},
];
