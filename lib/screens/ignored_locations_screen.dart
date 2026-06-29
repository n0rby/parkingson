import 'package:flutter/material.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/screen_scaffold.dart';

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
    return ScreenScaffold(
      title: 'Ignorerede placeringer',
      children: [
        Text('Alarmer vises ikke inden for ${ignoredLocationRadiusMeters.toInt()} meter fra disse steder.',
            style: const TextStyle(color: hpMuted)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => widget.onAddCurrentLocation((msg) => setState(() => _statusMessage = msg)),
            child: const Text('Tilføj nuværende placering'),
          ),
        ),
        if (_statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(_statusMessage!, style: const TextStyle(color: hpTeal)),
        ],
        const SizedBox(height: 12),
        const Text('Sortér efter', style: TextStyle(fontWeight: FontWeight.bold, color: hpText)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(label: const Text('Tidspunkt'), selected: _sortMode == IgnoredLocationSortMode.addedAt, onSelected: (_) => setState(() => _sortMode = IgnoredLocationSortMode.addedAt)),
            FilterChip(label: const Text('Navn'), selected: _sortMode == IgnoredLocationSortMode.name, onSelected: (_) => setState(() => _sortMode = IgnoredLocationSortMode.name)),
            FilterChip(label: const Text('Afstand'), selected: _sortMode == IgnoredLocationSortMode.distance, onSelected: (_) => setState(() => _sortMode = IgnoredLocationSortMode.distance)),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.ignoredLocations.isEmpty)
          ListCard(children: const [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ingen ignorerede placeringer', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Du kan tilføje en placering fra en påmindelse.', style: TextStyle(color: hpMuted, fontSize: 13)),
            ])),
          ])
        else
          ..._sorted.map((loc) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListCard(
              onTap: () => widget.onOpenMap(loc),
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(loc.name ?? 'Ignoreret placering', style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                  Text(loc.displayCoordinates, style: const TextStyle(color: hpMuted, fontSize: 12)),
                  Text('Tilføjet ${loc.displayCreatedAt}', style: const TextStyle(color: hpMuted, fontSize: 12)),
                  const Text('Tryk for at åbne i kort', style: TextStyle(color: hpTeal, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.delete_outline, color: hpMuted), onPressed: () => widget.onDelete(loc)),
              ],
            ),
          )),
        if (widget.ignoredLocations.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: widget.onClearAll, child: const Text('Slet alle', style: TextStyle(color: Colors.red))),
        ],
        TextButton(onPressed: widget.onBack, child: const Text('Tilbage til oversigt')),
      ],
    );
  }
}
