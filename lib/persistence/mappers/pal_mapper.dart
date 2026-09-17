import '../../domain/pal/pal_state.dart';
import '../../domain/time_delta/pal_stats.dart';
import '../entities/pal.dart';

PalState palEntityToState(Pal entity) {
  return PalState(
    id: entity.id,
    name: entity.name,
    createdAt: entity.createdAt,
    lastInteractionAt: entity.lastInteractionAt,
    stats: PalStats(hunger: entity.hunger, mood: entity.mood, energy: entity.energy),
    isActive: entity.isActive,
    archivedAt: entity.archivedAt,
    isFrozen: entity.isFrozen,
    frozenSince: entity.frozenSince,
    locationState: _locationStateFromString(entity.locationState),
    currentBiomeId: entity.currentBiome.targetId == 0 ? null : entity.currentBiome.targetId,
  );
}

// Uebernimmt alle vom Domain Core verwalteten Felder in die Entity. Relationen,
// die der Domain Core (noch) nicht kennt -- spriteAsset (Ingestion-Pipeline),
// difficultyModel (Skill-Level-Repository) -- bleiben unangetastet.
void applyPalStateToEntity(PalState state, Pal entity) {
  entity.name = state.name;
  entity.createdAt = state.createdAt;
  entity.lastInteractionAt = state.lastInteractionAt;
  entity.hunger = state.stats.hunger;
  entity.mood = state.stats.mood;
  entity.energy = state.stats.energy;
  entity.isActive = state.isActive;
  entity.archivedAt = state.archivedAt;
  entity.isFrozen = state.isFrozen;
  entity.frozenSince = state.frozenSince;
  entity.locationState = _locationStateToString(state.locationState);
  entity.currentBiome.targetId = state.currentBiomeId ?? 0;
}

PalLocationState _locationStateFromString(String value) {
  return value == 'exploring' ? PalLocationState.exploring : PalLocationState.home;
}

String _locationStateToString(PalLocationState value) {
  return value == PalLocationState.exploring ? 'exploring' : 'home';
}
