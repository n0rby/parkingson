import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/location_snapshot.dart';

class LocationService {
  Future<LocationSnapshot?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
        capturedAtMillis: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = [
        if (p.thoroughfare?.isNotEmpty == true) p.thoroughfare,
        if (p.subThoroughfare?.isNotEmpty == true) p.subThoroughfare,
      ];
      final street = parts.join(' ').trim();
      final city = p.locality ?? '';
      if (street.isEmpty && city.isEmpty) return null;
      if (street.isEmpty) return city;
      if (city.isEmpty) return street;
      return '$street, $city';
    } catch (_) {
      return null;
    }
  }

  Future<void> openInMaps(double latitude, double longitude, String label) async {
    final encoded = Uri.encodeComponent(label);
    final uri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encoded)');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    // Fallback to Google Maps web
    final fallback = Uri.parse(
        'https://maps.google.com/?q=$latitude,$longitude');
    if (await canLaunchUrl(fallback)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> navigateTo(double latitude, double longitude) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
