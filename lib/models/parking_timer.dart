import 'package:intl/intl.dart';

class ParkingTimer {
  final DateTime expiresAt;
  final double carLatitude;
  final double carLongitude;

  const ParkingTimer({
    required this.expiresAt,
    required this.carLatitude,
    required this.carLongitude,
  });

  Duration get remaining => expiresAt.difference(DateTime.now());
  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  String get displayExpiry => DateFormat('HH:mm').format(expiresAt);

  String encode() =>
      '${expiresAt.millisecondsSinceEpoch}|$carLatitude|$carLongitude';

  static ParkingTimer? decode(String value) {
    final parts = value.split('|');
    if (parts.length < 3) return null;
    final ms = int.tryParse(parts[0]);
    final lat = double.tryParse(parts[1]);
    final lon = double.tryParse(parts[2]);
    if (ms == null || lat == null || lon == null) return null;
    return ParkingTimer(
      expiresAt: DateTime.fromMillisecondsSinceEpoch(ms),
      carLatitude: lat,
      carLongitude: lon,
    );
  }
}
