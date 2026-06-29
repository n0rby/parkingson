import 'dart:math';
import 'package:intl/intl.dart';
import 'location_snapshot.dart';

const ignoredLocationRadiusMeters = 40.0;

class IgnoredLocation {
  final String id;
  final double latitude;
  final double longitude;
  final int createdAtMillis;
  final String? name;

  const IgnoredLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAtMillis,
    this.name,
  });

  String get displayCoordinates =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get displayCreatedAt {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  double distanceMetersTo(LocationSnapshot location) {
    const earthRadius = 6371000.0;
    final dLat = _toRad(location.latitude - latitude);
    final dLon = _toRad(location.longitude - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(latitude)) *
            cos(_toRad(location.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  String encode() =>
      '$id|$latitude|$longitude|$createdAtMillis|${name ?? ''}';

  static IgnoredLocation? decode(String value) {
    final parts = value.split('|');
    if (parts.length < 4) return null;
    return IgnoredLocation(
      id: parts[0],
      latitude: double.tryParse(parts[1]) ?? 0,
      longitude: double.tryParse(parts[2]) ?? 0,
      createdAtMillis: int.tryParse(parts[3]) ?? 0,
      name: parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null,
    );
  }
}
