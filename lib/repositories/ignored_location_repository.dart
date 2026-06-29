import 'package:shared_preferences/shared_preferences.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';

class IgnoredLocationRepository {
  static const _keyIgnoredLocations = 'ignored_locations';
  static const _keyLastParkingLocation = 'last_parking_location';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<IgnoredLocation>> getIgnoredLocations() async {
    final p = await _prefs;
    return (p.getStringList(_keyIgnoredLocations) ?? [])
        .map(IgnoredLocation.decode)
        .whereType<IgnoredLocation>()
        .toList();
  }

  Future<void> addIgnoredLocation(LocationSnapshot location, {String? name}) async {
    final current = await getIgnoredLocations();
    final withoutNearby = current
        .where((l) => l.distanceMetersTo(location) > ignoredLocationRadiusMeters)
        .toList();
    final updated = [
      ...withoutNearby,
      IgnoredLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: location.latitude,
        longitude: location.longitude,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        name: name,
      ),
    ];
    final p = await _prefs;
    await p.setStringList(_keyIgnoredLocations, updated.map((l) => l.encode()).toList());
  }

  Future<void> deleteIgnoredLocation(String id) async {
    final updated = (await getIgnoredLocations()).where((l) => l.id != id).toList();
    final p = await _prefs;
    await p.setStringList(_keyIgnoredLocations, updated.map((l) => l.encode()).toList());
  }

  Future<void> clearIgnoredLocations() async {
    final p = await _prefs;
    await p.remove(_keyIgnoredLocations);
  }

  Future<bool> isIgnored(LocationSnapshot location) async {
    final locations = await getIgnoredLocations();
    return locations.any((l) => l.distanceMetersTo(location) <= ignoredLocationRadiusMeters);
  }

  Future<LocationSnapshot?> getLastParkingLocation() async {
    final p = await _prefs;
    final encoded = p.getString(_keyLastParkingLocation);
    return encoded != null ? LocationSnapshot.decode(encoded) : null;
  }

  Future<void> saveLastParkingLocation(LocationSnapshot location) async {
    final p = await _prefs;
    await p.setString(_keyLastParkingLocation, location.encode());
  }

  Future<void> clearLastParkingLocation() async {
    final p = await _prefs;
    await p.remove(_keyLastParkingLocation);
  }
}
