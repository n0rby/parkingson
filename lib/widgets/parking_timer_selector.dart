import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/parking_timer.dart';
import '../repositories/parking_timer_repository.dart';
import '../theme.dart';

/// Reusable "remind me to walk back in time" card — the checkbox, quick-select
/// durations, and custom expiry time picker. Saves a [ParkingTimer] for the
/// given car location.
class ParkingTimerSelector extends StatefulWidget {
  final double carLatitude;
  final double carLongitude;

  /// When true, pre-fills from an already active timer (used when setting a
  /// reminder manually from the home screen). The reminder screen starts fresh.
  final bool loadExisting;

  const ParkingTimerSelector({
    super.key,
    required this.carLatitude,
    required this.carLongitude,
    this.loadExisting = false,
  });

  @override
  State<ParkingTimerSelector> createState() => _ParkingTimerSelectorState();
}

class _ParkingTimerSelectorState extends State<ParkingTimerSelector> {
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

  @override
  void initState() {
    super.initState();
    if (widget.loadExisting) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final timer = await _timerRepo.getActiveTimer();
    if (timer != null && mounted) {
      setState(() {
        _timerEnabled = true;
        _selectedDuration = timer.remaining;
      });
    }
  }

  String _formatDuration(Duration d, AppLocalizations l10n) {
    if (d.inMinutes < 60) return l10n.durationMinutes(d.inMinutes);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? l10n.durationHours(h) : l10n.durationHoursMinutes(h, m);
  }

  String _expiryDisplay(AppLocalizations l10n) {
    if (_selectedDuration == null) return l10n.pickTime;
    final expiry = DateTime.now().add(_selectedDuration!);
    final h = expiry.hour.toString().padLeft(2, '0');
    final m = expiry.minute.toString().padLeft(2, '0');
    return l10n.expiresAt('$h:$m');
  }

  Future<void> _pickCustomTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDuration != null
          ? TimeOfDay.fromDateTime(DateTime.now().add(_selectedDuration!))
          : TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute),
      helpText: AppLocalizations.of(context).pickExpiryTime,
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
      carLatitude: widget.carLatitude,
      carLongitude: widget.carLongitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
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
              Expanded(
                child: Text(
                  l10n.timerCheckbox,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: hpText),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Text(
              l10n.timerHelp,
              style: const TextStyle(color: hpMuted, fontSize: 13),
            ),
          ),
          if (_timerEnabled) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickDurations.map((d) {
                final selected = _selectedDuration == d;
                return ChoiceChip(
                  label: Text(_formatDuration(d, l10n)),
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
                      _expiryDisplay(l10n),
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
              Text(
                l10n.timerConfirmBody,
                style: const TextStyle(color: hpMuted, fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
