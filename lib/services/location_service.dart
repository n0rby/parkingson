// TODO: Implement using geolocator + geocoding
import '../models/location_snapshot.dart';

class LocationService {
  Future<LocationSnapshot?> getCurrentLocation() async {
    // TODO: Use Geolocator.getCurrentPosition()
    return null;
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    // TODO: Use geocoding package to get street address
    // Format: "Street number, City" e.g. "Pilehavevænge 75, Vallensbæk"
    return null;
  }

  void openInMaps(double latitude, double longitude, String label) {
    // TODO: Use url_launcher to open geo: URI or Google Maps
  }

  void navigateTo(double latitude, double longitude) {
    // TODO: Open navigation in maps app
  }
}
