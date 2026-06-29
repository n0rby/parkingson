import 'package:intl/intl.dart';

class LocationSnapshot {
  final double latitude;
  final double longitude;
  final int capturedAtMillis;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.capturedAtMillis,
  });

  String get displayCoordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get displayCapturedAt {
    final dt = DateTime.fromMillisecondsSinceEpoch(capturedAtMillis);
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String encode() => '$latitude|$longitude|$capturedAtMillis';

  static LocationSnapshot? decode(String value) {
    final parts = value.split('|');
    if (parts.length != 3) return null;
    return LocationSnapshot(
      latitude: double.tryParse(parts[0]) ?? 0,
      longitude: double.tryParse(parts[1]) ?? 0,
      capturedAtMillis: int.tryParse(parts[2]) ?? 0,
    );
  }
}
