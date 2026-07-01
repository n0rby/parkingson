import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../models/car_device.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/action_row.dart';
import '../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  final List<CarDevice> monitoredCars;
  final LocationSnapshot? lastParkingLocation;
  final bool isPremium;
  final VoidCallback onTestAlarm;
  final VoidCallback onManageCars;
  final VoidCallback onManageIgnoredLocations;
  final VoidCallback onFindCar;
  final VoidCallback onBuyApp;

  const HomeScreen({
    super.key,
    required this.monitoredCars,
    required this.lastParkingLocation,
    required this.isPremium,
    required this.onTestAlarm,
    required this.onManageCars,
    required this.onManageIgnoredLocations,
    required this.onFindCar,
    required this.onBuyApp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: hpBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parkingson',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: hpText)),
              const SizedBox(height: 12),
              StatusPill(label: l10n.monitoringActive),
              const SizedBox(height: 16),
              // Monitor card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastParkingLocation != null
                            ? l10n.lastParkedAt(lastParkingLocation!.displayCapturedAt)
                            : l10n.lastParkedNever,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: hpText),
                      ),
                      const SizedBox(height: 4),
                      const _MotionStatusLine(),
                      if (!isPremium) ...[
                        const SizedBox(height: 16),
                        const _BannerAdWidget(),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onBuyApp,
                            style: FilledButton.styleFrom(backgroundColor: hpOrange),
                            child: Text(l10n.removeAdsButton,
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _BatteryOptimizationCard(),
              const Divider(),
              ActionRow(
                title: l10n.testReminder,
                subtitle: l10n.testReminderDesc,
                onTap: onTestAlarm,
                accent: hpOrange,
              ),
              ActionRow(
                title: l10n.manageCars,
                subtitle: l10n.manageCarsDesc,
                onTap: onManageCars,
                accent: hpTeal,
              ),
              ActionRow(
                title: l10n.findCar,
                subtitle: lastParkingLocation != null
                    ? l10n.findCarRoute(lastParkingLocation!.displayCapturedAt)
                    : l10n.findCarNone,
                onTap: onFindCar,
              ),
              ActionRow(
                title: l10n.ignoredLocationsAction,
                subtitle: l10n.ignoredLocationsActionDesc,
                onTap: onManageIgnoredLocations,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional, non-blocking prompt to exempt the app from battery optimization.
/// Only shown when the app is NOT already exempt; hides itself once granted.
/// This is recommended (improves background reliability on Samsung etc.) but
/// never required — the app installs and runs without it.
class _BatteryOptimizationCard extends StatefulWidget {
  const _BatteryOptimizationCard();

  @override
  State<_BatteryOptimizationCard> createState() => _BatteryOptimizationCardState();
}

class _BatteryOptimizationCardState extends State<_BatteryOptimizationCard>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('dk.parkingson/alarm');
  bool _ignoring = true; // assume exempt until checked → card hidden by default
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    try {
      final v = await _channel.invokeMethod('isIgnoringBatteryOptimizations');
      if (mounted) setState(() => _ignoring = v == true);
    } catch (_) {}
  }

  Future<void> _request() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_ignoring || _dismissed) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hpCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hpOrange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.battery_saver_outlined, color: hpOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.batteryCardTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: const Icon(Icons.close, size: 18, color: hpSubtle),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.batteryCardBody,
            style: const TextStyle(fontSize: 12, color: hpMuted, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _request,
              style: FilledButton.styleFrom(backgroundColor: hpOrange),
              child: Text(l10n.batteryCardButton),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small live status line for the motion (Activity Recognition) subsystem,
/// shown under "Sidst parkeret" to make debugging easier.
class _MotionStatusLine extends StatefulWidget {
  const _MotionStatusLine();

  @override
  State<_MotionStatusLine> createState() => _MotionStatusLineState();
}

class _MotionStatusLineState extends State<_MotionStatusLine> {
  static const _channel = MethodChannel('dk.parkingson/alarm');
  Timer? _timer;
  Map<String, dynamic>? _status;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final result = await _channel.invokeMethod('getMotionStatus');
      if (!mounted || result is! Map) return;
      setState(() {
        _status = Map<String, dynamic>.from(result);
        _error = false;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  String _format(AppLocalizations l10n) {
    if (_error) return l10n.motionUnavailable;
    final s = _status;
    if (s == null) return l10n.motionFetching;

    final hasPermission = s['hasPermission'] == true;
    final registered = s['registered'] == true;
    final lastError = s['lastError'] as String?;
    final type = (s['lastActivityType'] as num?)?.toInt() ?? -1;
    final conf = (s['lastActivityConfidence'] as num?)?.toInt() ?? -1;
    final at = (s['lastActivityAt'] as num?)?.toInt() ?? 0;
    final inVehicleSince = (s['inVehicleSince'] as num?)?.toInt() ?? 0;
    final dormant = s['dormant'] == true;

    if (!hasPermission) return l10n.motionNoPermission;
    if (lastError != null && lastError.isNotEmpty) return l10n.motionError(lastError);
    if (!registered) return l10n.motionRegistering;

    final parts = <String>[dormant ? l10n.motionDormant : l10n.motionActive];
    if (type >= 0) {
      final label = _activityLabel(l10n, type);
      parts.add(conf >= 0 ? '$label $conf%' : label);
      if (at > 0) parts.add(_clock(at));
    } else {
      parts.add(l10n.motionWaitingData);
    }
    if (inVehicleSince > 0) parts.add(l10n.motionVehicleTimer);
    if (dormant) parts.add(l10n.motionWakesOnMovement);
    return parts.join(' · ');
  }

  String _activityLabel(AppLocalizations l10n, int t) => switch (t) {
        0 => l10n.activityInVehicle,
        1 => l10n.activityOnBicycle,
        2 => l10n.activityOnFoot,
        3 => l10n.activityStill,
        5 => l10n.activityTilting,
        7 => l10n.activityWalking,
        8 => l10n.activityRunning,
        _ => l10n.activityUnknown,
      };

  String _clock(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(AppLocalizations.of(context)),
      style: const TextStyle(fontSize: 11, color: hpSubtle),
    );
  }
}

const _kBannerAdUnitId = 'ca-app-pub-7290233540756156/5914841071';

class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: _kBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          setState(() => _bannerAd = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) return const SizedBox(height: 50);
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
