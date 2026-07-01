import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/list_card.dart';

enum IgnoredLocationSortMode { addedAt, name, distance }

class IgnoredLocationsScreen extends StatefulWidget {
  final List<IgnoredLocation> ignoredLocations;
  final LocationSnapshot? currentLocation;
  final void Function(IgnoredLocation) onDelete;
  final void Function(void Function(String)) onAddCurrentLocation;
  final VoidCallback onClearAll;
  final void Function(IgnoredLocation) onOpenMap;
  final VoidCallback onBack;

  const IgnoredLocationsScreen({
    super.key,
    required this.ignoredLocations,
    required this.currentLocation,
    required this.onDelete,
    required this.onAddCurrentLocation,
    required this.onClearAll,
    required this.onOpenMap,
    required this.onBack,
  });

  @override
  State<IgnoredLocationsScreen> createState() => _IgnoredLocationsScreenState();
}

class _IgnoredLocationsScreenState extends State<IgnoredLocationsScreen> {
  IgnoredLocationSortMode _sortMode = IgnoredLocationSortMode.addedAt;
  String? _statusMessage;

  List<IgnoredLocation> get _sorted {
    final list = List<IgnoredLocation>.from(widget.ignoredLocations);
    switch (_sortMode) {
      case IgnoredLocationSortMode.addedAt:
        list.sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
      case IgnoredLocationSortMode.name:
        list.sort((a, b) => (a.name ?? '￿').compareTo(b.name ?? '￿'));
      case IgnoredLocationSortMode.distance:
        if (widget.currentLocation != null) {
          list.sort((a, b) => a
              .distanceMetersTo(widget.currentLocation!)
              .compareTo(b.distanceMetersTo(widget.currentLocation!)));
        }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    l10n.ignoredLocationsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: hpText, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ignoredLocationsRadiusInfo(ignoredLocationRadiusMeters.toInt()),
                    style: const TextStyle(color: hpMuted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => widget.onAddCurrentLocation(
                          (msg) => setState(() => _statusMessage = msg)),
                      child: Text(l10n.addCurrentLocation),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_statusMessage!, style: const TextStyle(color: hpTeal)),
                  ],
                  const SizedBox(height: 12),
                  Text(l10n.sortBy,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text(l10n.sortTime),
                        selected: _sortMode == IgnoredLocationSortMode.addedAt,
                        onSelected: (_) => setState(
                            () => _sortMode = IgnoredLocationSortMode.addedAt),
                      ),
                      FilterChip(
                        label: Text(l10n.sortName),
                        selected: _sortMode == IgnoredLocationSortMode.name,
                        onSelected: (_) => setState(
                            () => _sortMode = IgnoredLocationSortMode.name),
                      ),
                      FilterChip(
                        label: Text(l10n.sortDistance),
                        selected: _sortMode == IgnoredLocationSortMode.distance,
                        onSelected: (_) => setState(
                            () => _sortMode = IgnoredLocationSortMode.distance),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Scrollable list ─────────────────────────────────────────────
            Expanded(
              child: widget.ignoredLocations.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListCard(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.noIgnoredLocations,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(l10n.noIgnoredLocationsBody,
                                  style: const TextStyle(color: hpMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      itemCount: _sorted.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _sorted.length) {
                          final loc = _sorted[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListCard(
                              onTap: () => widget.onOpenMap(loc),
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(loc.name ?? l10n.ignoredLocationDefault,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: hpText)),
                                      Text(loc.displayCoordinates,
                                          style: const TextStyle(
                                              color: hpMuted, fontSize: 12)),
                                      Text(l10n.addedAt(loc.displayCreatedAt),
                                          style: const TextStyle(
                                              color: hpMuted, fontSize: 12)),
                                      Text(l10n.tapToOpenMap,
                                          style: const TextStyle(
                                              color: hpTeal, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: hpMuted),
                                  onPressed: () => widget.onDelete(loc),
                                ),
                              ],
                            ),
                          );
                        }
                        // "Slet alle" at the bottom of the list
                        return TextButton(
                          onPressed: widget.onClearAll,
                          child: Text(l10n.deleteAll,
                              style: const TextStyle(color: Colors.red)),
                        );
                      },
                    ),
            ),

            // ── Fixed footer ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextButton(
                onPressed: widget.onBack,
                child: Text(l10n.backToOverview),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
