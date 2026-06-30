import 'package:flutter/material.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../models/parking_timer.dart';
import '../repositories/parking_timer_repository.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class ReminderScreen extends StatefulWidget {
  final LocationSnapshot parkingLocation;
  final VoidCallback onAddIgnoredLocation;
  final VoidCallback onNavigateToCar;
  final VoidCallback onDismiss;

  const ReminderScreen({
    super.key,
    required this.parkingLocation,
    required this.onAddIgnoredLocation,
    required this.onNavigateToCar,
    required this.onDismiss,
  });

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _timerRepo = ParkingTimerRepository();

  bool _timerEnabled = true;
  Duration? _selectedDuration;

  static const _quickDurations = [
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 3),
    Duration(hours: 4),
  ];

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? '$h t' : '$h t $m min';
  }

  String get _expiryDisplay {
    if (_selectedDuration == null) return 'Vælg tid';
    final expiry = DateTime.now().add(_selectedDuration!);
    final h = expiry.hour.toString().padLeft(2, '0');
    final m = expiry.minute.toString().padLeft(2, '0');
    return 'Udløber kl. $h:$m';
  }

  Future<void> _pickCustomTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDuration != null
          ? TimeOfDay.fromDateTime(DateTime.now().add(_selectedDuration!))
          : TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute),
      helpText: 'Vælg udløbstidspunkt',
    );
    if (picked == null) return;
    final today = DateTime.now();
    var expiry = DateTime(today.year, today.month, today.day, picked.hour, picked.minute);
    if (expiry.isBefore(today)) expiry = expiry.add(const Duration(days: 1));
    setState(() => _selectedDuration = expiry.difference(today));
    await _saveTimer();
  }

  Future<void> _saveTimer() async {
    if (!_timerEnabled || _selectedDuration == null) {
      await _timerRepo.clearTimer();
      return;
    }
    await _timerRepo.setTimer(ParkingTimer(
      expiresAt: DateTime.now().add(_selectedDuration!),
      carLatitude: widget.parkingLocation.latitude,
      carLongitude: widget.parkingLocation.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Husk at betale for parkering!',
      children: [
        const Text(
          'Vi har registreret at du har forladt din bil. Husk at betale for parkering!',
          style: TextStyle(fontSize: 16, color: hpText, height: 1.5),
        ),
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Koordinater',
          value: widget.parkingLocation.displayCoordinates,
        ),
        _InfoRow(
          icon: Icons.access_time,
          label: 'Registreret',
          value: widget.parkingLocation.displayCapturedAt,
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Find min bil', onPressed: widget.onNavigateToCar),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onAddIgnoredLocation,
            child: const Text('Ignorer altid denne placering'),
          ),
        ),

        // ── Parking timer ─────────────────────────────────────────────────
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: hpCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hpTeal.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _timerEnabled,
                    activeColor: hpTeal,
                    onChanged: (v) async {
                      setState(() => _timerEnabled = v ?? false);
                      await _saveTimer();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Påmind mig om at gå tilbage i tide',
                    style: TextStyle(fontWeight: FontWeight.bold, color: hpText),
                  ),
                ],
              ),
              if (_timerEnabled) ...[
                const SizedBox(height: 12),
                // Quick-select buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickDurations.map((d) {
                    final selected = _selectedDuration == d;
                    return ChoiceChip(
                      label: Text(_formatDuration(d)),
                      selected: selected,
                      selectedColor: hpTeal,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : hpText,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) async {
                        setState(() => _selectedDuration = d);
                        await _saveTimer();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Expiry display — tap for custom time
                GestureDetector(
                  onTap: _pickCustomTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: hpBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedDuration != null
                            ? hpTeal
                            : hpMuted.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: _selectedDuration != null ? hpTeal : hpMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _expiryDisplay,
                          style: TextStyle(
                            color: _selectedDuration != null ? hpTeal : hpMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_outlined, color: hpMuted, size: 14),
                      ],
                    ),
                  ),
                ),
                if (_selectedDuration != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Du får besked i god tid til at gå tilbage til bilen.',
                    style: TextStyle(color: hpMuted, fontSize: 12),
                  ),
                ],
              ],
            ],
          ),
        ),
        // ─────────────────────────────────────────────────────────────────

        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Luk'),
        ),
        const SizedBox(height: 12),
        Text(
          'Tryk "Ignorer altid" for steder som hjemme eller arbejde, '
          'hvor du sjældent skal betale for parkering. '
          'Alarmen vises ikke igen inden for ${ignoredLocationRadiusMeters.toInt()} meter herfra.',
          style: const TextStyle(color: hpMuted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: hpTeal),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: hpMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: hpText, fontSize: 13)),
        ],
      ),
    );
  }
}
