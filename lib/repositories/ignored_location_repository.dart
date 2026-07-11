import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';

class IgnoredLocationRepository {
  static const _keyIgnoredLocations = 'ignored_locations';
  static const _keyLastParkingLocation = 'last_parking_location';

  // Ignored locations are the user's home/work — the most privacy-sensitive
  // data — so they live in Keystore-backed encrypted storage rather than plain
  // SharedPreferences. Invisible to the user (no password), and the encryption
  // key never leaves the device, so cloud backups of it can't be decrypted.
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<IgnoredLocation>> getIgnoredLocations() async {
    await _migrateFromPlaintext();
    String? raw;
    try {
      raw = await _secure.read(key: _keyIgnoredLocations);
    } catch (_) {
      return [];
    }
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => IgnoredLocation.decode(e as String))
          .whereType<IgnoredLocation>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(List<IgnoredLocation> list) async {
    try {
      await _secure.write(
        key: _keyIgnoredLocations,
        value: jsonEncode(list.map((l) => l.encode()).toList()),
      );
    } catch (_) {}
  }

  Future<void> addIgnoredLocation(LocationSnapshot location, {String? name}) async {
    final current = await getIgnoredLocations();
    final withoutNearby = current
        .where((l) => l.distanceMetersTo(location) > ignoredLocationRadiusMeters)
        .toList();
    await _saveList([
      ...withoutNearby,
      IgnoredLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: location.latitude,
        longitude: location.longitude,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        name: name,
      ),
    ]);
  }

  Future<void> deleteIgnoredLocation(String id) async {
    final updated =
        (await getIgnoredLocations()).where((l) => l.id != id).toList();
    await _saveList(updated);
  }

  Future<void> clearIgnoredLocations() async {
    try {
      await _secure.delete(key: _keyIgnoredLocations);
    } catch (_) {}
  }

  Future<bool> isIgnored(LocationSnapshot location) async {
    final locations = await getIgnoredLocations();
    return locations
        .any((l) => l.distanceMetersTo(location) <= ignoredLocationRadiusMeters);
  }

  /// One-time move of any pre-existing plaintext ignored locations from
  /// SharedPreferences into encrypted storage, then delete the plaintext (which
  /// also removes it from cloud backups).
  Future<void> _migrateFromPlaintext() async {
    final p = await _prefs;
    final old = p.getStringList(_keyIgnoredLocations);
    if (old == null) return;
    try {
      final existing = await _secure.read(key: _keyIgnoredLocations);
      if (existing == null || existing.isEmpty) {
        await _secure.write(key: _keyIgnoredLocations, value: jsonEncode(old));
      }
    } catch (_) {}
    await p.remove(_keyIgnoredLocations);
  }

  // last_parking_location stays in SharedPreferences: it's transient, not
  // privacy-critical here, and the native dormancy check reads its presence.
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
