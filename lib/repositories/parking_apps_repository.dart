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

  /// The selected apps resolved to full [InstalledApp]s (with labels), so they
  /// can be shown as launch buttons. Falls back to the package name as label if
  /// the app is no longer installed.
  Future<List<InstalledApp>> getSelectedApps() async {
    final selected = await getSelected();
    if (selected.isEmpty) return [];
    final all = await getInstalledApps();
    final byPackage = {for (final a in all) a.packageName: a};
    return selected
        .map((p) => byPackage[p] ?? InstalledApp(packageName: p, label: p))
        .toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }

  /// Opens the given app. Returns false if it isn't installed / can't launch.
  Future<bool> launchApp(String packageName) async {
    try {
      final r = await _channel.invokeMethod('launchApp', {'package': packageName});
      return r == true;
    } catch (_) {
      return false;
    }
  }

  /// The app's launcher icon as PNG bytes, or null if unavailable.
  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final r = await _channel.invokeMethod('getAppIcon', {'package': packageName});
      return r is Uint8List ? r : null;
    } catch (_) {
      return null;
    }
  }
}
