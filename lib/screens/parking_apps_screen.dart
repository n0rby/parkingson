import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../repositories/parking_apps_repository.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/primary_button.dart';

/// Lets the user mark which installed apps they use to pay for parking.
/// Used both as a Setup submenu ([onBack]) and as a step in the initial setup
/// flow ([onContinue] shows a primary "finish" button).
class ParkingAppsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const ParkingAppsScreen({super.key, this.onBack, this.onContinue});

  @override
  State<ParkingAppsScreen> createState() => _ParkingAppsScreenState();
}

class _ParkingAppsScreenState extends State<ParkingAppsScreen> {
  final _repo = ParkingAppsRepository();

  List<InstalledApp> _apps = [];
  Set<String> _selected = {};
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await _repo.getInstalledApps();
    final selected = await _repo.getSelected();
    if (mounted) {
      setState(() {
        _apps = apps;
        _selected = selected;
        _loading = false;
      });
    }
  }

  void _toggle(String pkg, bool checked) {
    setState(() {
      final updated = Set<String>.from(_selected);
      if (checked) {
        updated.add(pkg);
      } else {
        updated.remove(pkg);
      }
      _selected = updated;
    });
    _repo.setSelected(_selected);
  }

  List<Object> _rows(AppLocalizations l10n) {
    final q = _query.trim().toLowerCase();
    final filtered = _apps.where((a) {
      if (q.isEmpty) return true;
      return '${a.label} ${a.packageName}'.toLowerCase().contains(q);
    }).toList();
    final known = filtered.where(looksLikeParkingApp).toList();
    final others = filtered.where((a) => !looksLikeParkingApp(a)).toList();

    final rows = <Object>[];
    if (known.isNotEmpty) {
      rows.add(l10n.parkingAppsKnown);
      rows.addAll(known);
    }
    if (others.isNotEmpty) {
      rows.add(l10n.parkingAppsOther);
      rows.addAll(others);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = _rows(l10n);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.parkingAppsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: hpText, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.parkingAppsBody, style: const TextStyle(color: hpMuted, height: 1.4)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.parkingAppsSearch,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Scrollable app list ─────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : rows.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(l10n.parkingAppsNone,
                              style: const TextStyle(color: hpMuted)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          itemCount: rows.length,
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            if (row is String) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 6),
                                child: Text(row,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: hpText)),
                              );
                            }
                            final app = row as InstalledApp;
                            final selected = _selected.contains(app.packageName);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListCard(
                                onTap: () => _toggle(app.packageName, !selected),
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(app.label,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600, color: hpText)),
                                        Text(app.packageName,
                                            style: const TextStyle(
                                                color: hpMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: selected,
                                    activeColor: hpTeal,
                                    onChanged: (v) => _toggle(app.packageName, v ?? false),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // ── Fixed footer ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                children: [
                  if (widget.onContinue != null)
                    PrimaryButton(label: l10n.finishSetup, onPressed: widget.onContinue),
                  if (widget.onBack != null)
                    TextButton(
                      onPressed: widget.onBack,
                      child: Text(l10n.backToOverview),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
