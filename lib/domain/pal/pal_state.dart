import '../time_delta/pal_stats.dart';

// Zuhause/Erkundung (Kernsystem 5): Aktionstypen sind ein thematischer Layer
// ueber der Task Engine, keine eigenstaendigen Spielmodi.
enum PalLocationState { home, exploring }

// Domain-seitiges Pendant zur Pal-Entity (Persistenz, Kernsystem 4) --
// der Domain Core kennt keine ObjectBox-Typen. id spiegelt die dortige
// ObjectBox-Id, damit Repository-Implementierungen ohne Uebersetzungsschicht
// laden/speichern koennen.
class PalState {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime lastInteractionAt;
  final PalStats stats;

  // Sammlungsmodell (resolved): alte Pals bleiben als Sammlung erhalten.
  final bool isActive;
  final DateTime? archivedAt;

  // Leniency-Policy (resolved).
  final bool isFrozen;
  final DateTime? frozenSince;

  final PalLocationState locationState;
  final int? currentBiomeId;

  const PalState({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastInteractionAt,
    required this.stats,
    required this.isActive,
    this.archivedAt,
    required this.isFrozen,
    this.frozenSince,
    required this.locationState,
    this.currentBiomeId,
  });

  PalState copyWith({
    DateTime? lastInteractionAt,
    PalStats? stats,
    bool? isActive,
    DateTime? archivedAt,
    bool? isFrozen,
    DateTime? frozenSince,
    PalLocationState? locationState,
    int? currentBiomeId,
  }) {
    return PalState(
      id: id,
      name: name,
      createdAt: createdAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
      archivedAt: archivedAt ?? this.archivedAt,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenSince: frozenSince ?? this.frozenSince,
      locationState: locationState ?? this.locationState,
      currentBiomeId: currentBiomeId ?? this.currentBiomeId,
    );
  }
}
