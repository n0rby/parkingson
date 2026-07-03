import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstalledApp {
  final String packageName;
  final String label;
  const InstalledApp({required this.packageName, required this.label});
}

// Keywords that mark an installed app as a likely parking app, so those are
// grouped at the top of the list.
const _parkingKeywords = [
  'easypark', 'q-park', 'qpark', 'apcoa', 'parkman', 'parkone', 'onepark',
  'aimo', 'parkering', 'mobilparkering', 'parkster', 'flowbird',
];

bool looksLikeParkingApp(InstalledApp app) {
  final s = '${app.label} ${app.packageName}'.toLowerCase();
  return _parkingKeywords.any((k) => s.contains(k));
}

class ParkingAppsRepository {
  static const _channel = MethodChannel('dk.parkingson/alarm');
  static const _key = 'parking_apps';

  /// Launchable apps installed on the device (via native PackageManager).
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result is! List) return [];
      return result
          .map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return InstalledApp(
              packageName: m['package'] as String? ?? '',
              label: m['label'] as String? ?? '',
            );
          })
          .where((a) => a.packageName.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Set<String>> getSelected() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<void> setSelected(Set<String> packages) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, packages.toList());
  }
}
