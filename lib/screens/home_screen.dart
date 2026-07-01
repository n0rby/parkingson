import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
              const StatusPill(label: 'Overvågning aktiv'),
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
                            ? 'Sidst parkeret ${lastParkingLocation!.displayCapturedAt}'
                            : 'Sidst parkeret ikke målt endnu',
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
                            child: const Text('Slip for reklamer og støt en rar programmør. Næsten gratis!',
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
                title: 'Test påmindelse',
                subtitle: 'Se notifikation, sirene og stemme',
                onTap: onTestAlarm,
                accent: hpOrange,
              ),
              ActionRow(
                title: 'Administrer biler',
                subtitle: 'Tilføj, fjern eller skift biler',
                onTap: onManageCars,
                accent: hpTeal,
              ),
              ActionRow(
                title: 'Find min bil',
                subtitle: lastParkingLocation != null
                    ? 'Rute til sidst parkeret ${lastParkingLocation!.displayCapturedAt}'
                    : 'Ingen parkeringsplacering gemt endnu',
                onTap: onFindCar,
              ),
              ActionRow(
                title: 'Ignorerede lokationer',
                subtitle: 'Steder der ikke udløser alarm',
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
              const Expanded(
                child: Text('Anbefalet: undtag fra batterioptimering',
                    style: TextStyle(fontWeight: FontWeight.bold, color: hpText)),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: const Icon(Icons.close, size: 18, color: hpSubtle),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Valgfrit. Uden dette kan Android (især Samsung) stoppe '
            'bevægelsesovervågningen i baggrunden, så parkering uden Bluetooth '
            'ikke altid opdages.',
            style: TextStyle(fontSize: 12, color: hpMuted, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _request,
              style: FilledButton.styleFrom(backgroundColor: hpOrange),
              child: const Text('Tillad ubegrænset baggrund'),
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
  String _text = 'Motion: henter status…';

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
      setState(() => _text = _format(Map<String, dynamic>.from(result)));
    } catch (_) {
      if (mounted) setState(() => _text = 'Motion: status utilgængelig');
    }
  }

  String _format(Map<String, dynamic> s) {
    final hasPermission = s['hasPermission'] == true;
    final registered = s['registered'] == true;
    final lastError = s['lastError'] as String?;
    final type = (s['lastActivityType'] as num?)?.toInt() ?? -1;
    final conf = (s['lastActivityConfidence'] as num?)?.toInt() ?? -1;
    final at = (s['lastActivityAt'] as num?)?.toInt() ?? 0;
    final inVehicleSince = (s['inVehicleSince'] as num?)?.toInt() ?? 0;
    final dormant = s['dormant'] == true;

    if (!hasPermission) return 'Motion: ingen tilladelse til fysisk aktivitet';
    if (lastError != null && lastError.isNotEmpty) return 'Motion-fejl: $lastError';
    if (!registered) return 'Motion: registrerer…';

    final parts = <String>[dormant ? 'Motion i dvale' : 'Motion aktiv'];
    if (type >= 0) {
      final label = _activityLabel(type);
      parts.add(conf >= 0 ? '$label $conf%' : label);
      if (at > 0) parts.add(_clock(at));
    } else {
      parts.add('afventer data');
    }
    if (inVehicleSince > 0) parts.add('bil-timer kører');
    if (dormant) parts.add('vågner ved bevægelse');
    return parts.join(' · ');
  }

  String _activityLabel(int t) => switch (t) {
        0 => 'I bil',
        1 => 'På cykel',
        2 => 'Til fods',
        3 => 'Stille',
        5 => 'Vipper',
        7 => 'Går',
        8 => 'Løber',
        _ => 'Ukendt',
      };

  String _clock(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
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
