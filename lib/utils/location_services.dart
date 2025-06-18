import 'package:location/location.dart';

class LocationServices {
  Location location = Location();
  Future<bool> checkAndRequestGPS() async {
    var isEnabled = await location.serviceEnabled();
    if (!isEnabled) {
      isEnabled = await location.requestService();
    }
    return isEnabled;
  }

  Future<bool> checkAndRequestPermession() async {
    PermissionStatus permissionStatus;
    permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited;
  }

  void getLocation(void Function(LocationData)? onData) async {
    location.changeSettings(distanceFilter: 2);
    location.onLocationChanged.listen(onData);
  }
}
