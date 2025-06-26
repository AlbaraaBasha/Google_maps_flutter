import 'package:location/location.dart';

class LocationServices {
  Location location = Location();
  Future<void> checkAndRequestGPS() async {
    var isEnabled = await location.serviceEnabled();
    if (!isEnabled) {
      isEnabled = await location.requestService();
      if (!isEnabled) {
        throw LocationServiceGPSException();
      }
    }
  }

  Future<void> checkAndRequestPermession() async {
    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.deniedForever) {
      throw LocationServicePermissionException();
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    if (permissionStatus != PermissionStatus.granted &&
        permissionStatus != PermissionStatus.grantedLimited) {
      throw LocationServicePermissionException();
    }
  }

  void getRealTimeLocation(void Function(LocationData)? onData) async {
    await checkAndRequestGPS();
    await checkAndRequestPermession();
    location.changeSettings(distanceFilter: 2);
    location.onLocationChanged.listen(onData);
  }

  Future<LocationData> getLocation() async {
    await checkAndRequestGPS();
    await checkAndRequestPermession();
    var locationData = await location.getLocation();
    return locationData;
  }
}

class LocationServiceGPSException implements Exception {}

class LocationServicePermissionException implements Exception {}
