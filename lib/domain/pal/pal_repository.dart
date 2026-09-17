import 'pal_state.dart';

// Vom Domain Core definierte Schnittstelle (Dependency Inversion) -- die
// tatsaechliche ObjectBox-Implementierung liegt in persistence/repositories,
// damit der Domain Core persistenzunabhaengig bleibt.
abstract class PalRepository {
  // Das aktuell aktive Pal des Kindes, falls vorhanden.
  Future<PalState?> getActive();

  // Sammlungsmodell (resolved): aktive und archivierte Pals zusammen.
  Future<List<PalState>> getAll();

  // Legt ein neues Pal an (PalState.id == 0) oder aktualisiert ein bestehendes.
  // Gibt den gespeicherten Zustand inkl. vergebener Id zurueck.
  Future<PalState> save(PalState pal);
}
