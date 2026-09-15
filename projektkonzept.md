# Lernspiel-App: Projektkonzept

## Übersicht

Cross-Platform Tamagotchi-artige Lern-App für Vorschulkinder (4-6 Jahre). Ein virtuelles Haustier ("Pet") wird durch das Lösen altersgerechter Matheaufgaben gepflegt statt durch simples Antippen. Kinder können außerdem eigene Zeichnungen fotografieren, die automatisch in spielbare Pixel-Art-Charaktere umgewandelt werden.

**Zielgruppe:** Vorschulkinder, 4-6 Jahre
**Plattformen:** iOS & Android (Wearables als Phase 2 vorgesehen)
**Monetarisierung:** Kostenlos
**Offline-first:** Ja — keine Server-Simulation, keine Cloud-Pflicht für Kernfunktionen
**Visueller Stil:** 16-Bit-Pixel-Art mit Emotes, Inventarsystem, reichhaltigeren Interaktionen

---

## Tech Stack

- **Framework:** Flutter (ein Codebase für iOS/Android, Skia/Impeller-Rendering eignet sich gut für Sprite-Animation)
- **Lokale Persistenz:** **ObjectBox** (empfohlen — aktiv gepflegt, gute Performance für Flutter). *Isar und Hive sind beide von ihren Original-Autoren aufgegeben worden und daher für ein neues Langzeitprojekt nicht zu empfehlen.* **Drift** als Fallback, falls ObjectBox im Team-Review nicht durchgeht.
- **On-Device ML:** **Google ML Kit Subject Segmentation** als primäre Lösung (vorgefertigt, schnellster Einstieg, gute Qualität). **MODNet via `tflite_flutter`** als Fallback, falls mehr Anpassbarkeit nötig ist.
- **Zukünftige Wearable-Targets (Phase 2):** WatchKit/SwiftUI (Apple Watch), Kotlin/Compose (Wear OS) — jeweils eigene native Codebases

> ⚠️ **Team-Validierung ausstehend:** Der Wechsel weg von Isar/Hive hin zu ObjectBox ist eine materielle Änderung gegenüber früheren Annahmen und sollte vor Beginn der Datenmodellierung vom Team abgesegnet werden.

---

## Architektur (Schichtenmodell)

```
Character Ingestion Pipeline (neu)
        ↓
Presentation
        ↓
Domain Core
  ├─ Time-Delta Engine (Stat-Verfall, mit Leniency-Policy)
  ├─ Task Engine (Aufgaben-Generierung & -Bewertung)
  │    ├─ DifficultyModel (pro Pet, monoton steigend)
  │    ├─ TaskGenerator
  │    ├─ ResponseTracker (rollierender Schnitt: Zeit + Korrektheit)
  │    └─ SkillEvaluator (erkennt Skill Gap)
  └─ Pet/Pal State Management (Sammlungsmodell)
        ↓
Local Persistence (ObjectBox)
```

**Phase 2 (optional, entkoppelt):** Cloud Sync, Wearable Companion Apps

Der Domain Core ist bewusst von Persistenz und UI entkoppelt, um spätere Erweiterungen (Cloud-Sync, Wearables) ohne Kernumbau zu ermöglichen. Das gilt insbesondere für die Wearable-Companion-Architektur (Phase 2): Pet-State, Regeln und Time-Delta-Engine müssen sauber von Persistenz- und UI-Schicht getrennt bleiben, damit sie später von einer nativen Watch-App wiederverwendet werden können.

---

## Kernsystem 1: Pet-Zustand & Zeitverfall

- Werte (Hunger, Laune, Energie, …) verfallen über Zeit
- Berechnung per **Time-Delta beim App-Öffnen** (keine Server-seitige Simulation)
- **Auffüllen der Werte NICHT durch Antippen**, sondern durch Lösen von Matheaufgaben (Task Engine)

### Leniency-Policy (resolved)
- **Minimaler Stat-Boden bei ~20 %** — Werte fallen bei langer Abwesenheit nie auf 0, sondern werden bei diesem Floor eingefroren
- Nach **3 Tagen Abwesenheit** wechselt das Pet in einen **Freeze-/Maintenance-Modus**: kein weiterer Verfall, aber auch kein Fortschritt
- **Sanfter Wiedereinstieg (Soft Re-Entry):** Beim nächsten Öffnen wird das Kind nicht mit stark abgefallenen Werten "bestraft", sondern über eine kurze, freundliche Wiedereinstiegs-Sequenz (z. B. 1-2 leichte Aufgaben) zurück ins Spiel geführt

---

## Kernsystem 2: Task Engine (Lern-Mechanik)

### Aufgaben-Progression (Beispiel Mathematik, graduell steigend)
1. **Piktogramme/Mengen** – "Wie viele Äpfel?" (rein visuelles Zählen, 1-5)
2. **Mengenvergleich** – "Welcher Haufen hat mehr?" (visuell, kein Rechnen)
3. **Visuelle Addition** – Symbole kombinieren, Ergebnis antippen
4. **Abstrakte Zahlen** – erste Ziffern-basierte Aufgaben ohne Bildhilfe
5. **Erweiterter Zahlenraum** – je nach Fortschritt

Mathematik ist nur *eine* Kategorie unter mehreren (siehe To-Do 2 für die weiteren Fachbereiche Sprache/Biologie/Physik/Musik) — jede Kategorie bekommt ihre eigene Progression und wird im Datenmodell über einen eigenen `categoryKey` (z. B. `math.pictogram`) abgebildet, siehe Kernsystem 4.

Aufgaben werden außerdem nicht mehr nur beim Füttern zuhause gestellt, sondern auch während Erkundungen/Kämpfen/Geheimnissen in Biomen — die Kategorie/Progression bleibt dieselbe, nur der thematische Rahmen (`Activity`) ändert sich, siehe Kernsystem 5.

### Aufgaben-Format (resolved)
- **Bild + Audio als Standard** — jede Aufgabe wird zusätzlich zur visuellen Darstellung vorgelesen/vertont
- **Text ist optional und nie verpflichtend** — passend zur Zielgruppe, die überwiegend noch nicht sicher lesen kann

### Adaptive Difficulty
- Skill-Signal: **rollierender Durchschnitt** aus Lösungsgeschwindigkeit + Korrektheit (nicht Einzelmessung — Streuung durch Aufmerksamkeitsspanne/Motorik bei Kleinkindern wird geglättet)
- **DifficultyModel pro Pet ist monoton** — sinkt nie, auch nicht bei schwacher Performance
- Bei anhaltendem negativem Skill Gap: **kein Downgrade** des aktuellen Pets, stattdessen Angebot, einen **neuen Pal aufzuziehen**, der bei passenderem (niedrigerem) Level startet

### Pet-Collection-Modell (resolved)
- **Sammlung (Accumulation):** Alte Pets bleiben nach einem Pal-Wechsel als Sammlung erhalten, statt ersetzt zu werden
- Beeinflusst das Datenmodell direkt: Pet/Pal-Schema muss als **Collection**, nicht als Single-Active-Pet, ausgelegt werden

---

## Kernsystem 3: Character Ingestion Pipeline (Foto → Spielfigur)

**Primärer Weg: kein klassischer Charakter-Designer, keine vorgefertigten Figuren.** Kinder fotografieren eigene Zeichnungen, die automatisiert zu spielbaren Sprites werden. *Für jüngere Kinder gibt es zusätzlich einen Baukasten-Designer als Alternative/Ergänzung — siehe Kernsystem 6.*

### Pipeline
```
Foto-Aufnahme (Kamera/Galerie)
   → On-Device ML-Segmentierung (Vordergrund/Hintergrund-Trennung)
   → Freistellen + Zuschnitt
   → Farbquantisierung (16-Bit-Palette)
   → Pixelation (Downsampling auf Sprite-Raster)
   → Prozedurale Animation (Idle-Wobble, Blink-Overlay)
   → Speicherung als Sprite-Asset (nicht das Rohfoto)
```

### Entscheidung: On-Device ML-Segmentierung
Gewählt statt (a) rein klassischer Bildverarbeitung oder (b) Cloud-KI — bewahrt offline-first & kostenlos-Anspruch bei besserer Qualität als klassische Ansätze. Cloud-basierte KI-Konvertierung wurde bewusst verworfen, um die Offline-first-Anforderung und die Kostenfreiheit nicht zu gefährden.

**Segmentierungsmodell (resolved):**
- **Google ML Kit Subject Segmentation** als primäre Lösung — vorgefertigt, schnellster Einstieg, gute Qualität ohne eigenes Modelltraining
- **MODNet via `tflite_flutter`** als Fallback, falls ML Kit in der Praxis (z. B. bei handgezeichneten Kinder-Motiven) nicht überzeugt oder mehr Kontrolle nötig ist

**Animation:** Da nur ein einzelnes Quellbild existiert, ist echte Frame-für-Frame-Animation nicht möglich — Animation erfolgt prozedural (Transform-basiert: Wackeln, Hüpfen, Blinzeln-Overlay). Das ist der einzig praktikable Animationsansatz angesichts der Ein-Bild-pro-Charakter-Einschränkung.

**Trade-off:** Modellgröße wirkt sich auf App-Größe aus (typisch wenige MB bis ~20+ MB je nach Modellvariante) — relevant für Installationshürde bei Eltern.

---

## Kernsystem 4: Datenmodell (ObjectBox-Entities)

### Entities

```dart
// --- Pal (ehemals "Pet") ---
@Entity()
class Pal {
  @Id()
  int id = 0;

  String name = '';
  DateTime createdAt = DateTime.now();
  DateTime lastInteractionAt = DateTime.now();

  // Stats (0.0 - 1.0, floor bei 0.2 durch Time-Delta Engine erzwungen)
  double hunger = 1.0;
  double mood = 1.0;
  double energy = 1.0;

  // Sammlungsmodell: aktives vs. archiviertes Pal
  bool isActive = true;
  DateTime? archivedAt;

  // Freeze-Status (Leniency-Policy)
  bool isFrozen = false;
  DateTime? frozenSince;

  final spriteAsset = ToOne<SpriteAsset>();      // 1:1 — reicht fürs Erste
  final difficultyModel = ToOne<DifficultyModel>();

  // Zuhause-/Erkundungs-Status
  String locationState = 'home';    // 'home' | 'exploring'
  final currentBiome = ToOne<Biome>();  // gesetzt, während exploring

  @Backlink('pal')
  final taskHistory = ToMany<TaskRecord>();

  @Backlink('pal')
  final activityHistory = ToMany<Activity>();
}

// --- Sprite Asset (Ergebnis der Ingestion Pipeline) ---
@Entity()
class SpriteAsset {
  @Id()
  int id = 0;

  String spriteFilePath = '';       // finales Pixel-Art-Asset, nicht das Rohfoto
  String paletteId = '';            // referenziert 16-Bit-Palette
  int spriteWidth = 0;
  int spriteHeight = 0;
  DateTime createdAt = DateTime.now();

  // Segmentierungs-Metadaten (fürs Debugging/Re-Processing)
  String segmentationModel = '';    // 'mlkit' | 'modnet'
  double segmentationConfidence = 0.0;

  // Herkunft & Charakter-Designer
  String sourceType = 'photo';      // 'photo' | 'designer'
  String designMode = 'none';       // 'none' | 'guided' | 'free'
}

// --- Difficulty Model (pro Pal, generisch über beliebig viele Fachbereiche/Kategorien) ---
@Entity()
class DifficultyModel {
  @Id()
  int id = 0;

  @Backlink('difficultyModel')
  final skillLevels = ToMany<SkillLevel>();
}

// --- Einzelnes Skill-Level (ein Eintrag pro Kategorie, z.B. 'math.pictogram', 'german.vocabulary', 'music.rhythm') ---
@Entity()
class SkillLevel {
  @Id()
  int id = 0;

  final difficultyModel = ToOne<DifficultyModel>();
  String categoryKey = '';   // z. B. 'math.pictogram', 'math.comparison', 'german.vocabulary', 'biology.animals', 'music.rhythm'
  int level = 1;             // monoton, sinkt nie
  DateTime lastLevelUpAt = DateTime.now();
}

// --- Task/Response-Historie ---
@Entity()
class TaskRecord {
  @Id()
  int id = 0;

  final pal = ToOne<Pal>();
  final activity = ToOne<Activity>();   // unset bei "normalem" Füttern zuhause ohne Biome-Kontext

  String categoryKey = '';          // z. B. 'math.pictogram', 'german.vocabulary' — matched SkillLevel.categoryKey
  int difficultyAtTime = 1;
  bool wasCorrect = false;
  int responseTimeMs = 0;
  DateTime completedAt = DateTime.now();

  // für Audio+Bild-Format: welche Variante wurde gezeigt
  String presentationMode = 'image_audio';
}

// --- Biom/Gebiet (Erkundungsziel außerhalb des Zuhauses) ---
@Entity()
class Biome {
  @Id()
  int id = 0;

  String name = '';                 // z. B. "Zauberwald", "Kristallhöhle"
  int difficultyTier = 1;           // grobe Gesamt-Schwierigkeit des Biomes
  String themeAssetPath = '';       // Hintergrund/Deko-Sprites
  int unlockMinPalLevel = 1;        // ab welchem Skill-Level freigeschaltet
}

// --- Activity (bündelt Aufgaben unter einem Thema: Füttern / Erkunden / Geheimnis / Kampf) ---
@Entity()
class Activity {
  @Id()
  int id = 0;

  final pal = ToOne<Pal>();
  final biome = ToOne<Biome>();     // unset bei 'feeding' zuhause

  String activityType = '';         // 'feeding' | 'exploration' | 'mystery' | 'battle'
  int requiredTaskCount = 1;
  DateTime startedAt = DateTime.now();
  DateTime? completedAt;

  @Backlink('activity')
  final taskRecords = ToMany<TaskRecord>();
}
// --- Kind-Profil (steuert u.a. geführten vs. freien Design-Modus) ---
@Entity()
class ChildProfile {
  @Id()
  int id = 0;

  String name = '';
  int ageYears = 4;             // von den Eltern im Profil-Setup eingegeben
  DateTime createdAt = DateTime.now();
}

// --- Wählbare Bauteile für den Charakter-Designer ---
@Entity()
class CharacterComponentOption {
  @Id()
  int id = 0;

  String componentSlot = '';    // 'bodyShape' | 'primaryColor' | 'eyes' | 'accessory' | 'pattern'
  String assetPath = '';        // Sprite-Bauteil-Asset
  String displayLabel = '';     // z. B. für Screenreader/Audio-Hinweis

  bool guidedModeEligible = true;   // im geführten Prozess für jüngere Kinder wählbar
}

// --- Konkrete Auswahl, verknüpft mit einem SpriteAsset ---
@Entity()
class SpriteComponentSelection {
  @Id()
  int id = 0;

  final spriteAsset = ToOne<SpriteAsset>();
  final componentOption = ToOne<CharacterComponentOption>();
}
```

### Skill-Evaluator: Rolling-Average-Fenster (resolved)

Die Fenstergröße für den rollierenden Durchschnitt wächst **pro `categoryKey` separat** (z. B. `math.pictogram`, `german.vocabulary`, `music.rhythm` jeweils eigenständig), abhängig vom jeweiligen `SkillLevel.level` dieser Kategorie — nicht global über alle Kategorien. Höhere Level erfordern also mehr Datenpunkte, bevor eine Level-Up-Entscheidung getroffen wird (mehr Stabilität, weniger Ausreißer-Anfälligkeit). Da Kategorien jetzt generisch als `SkillLevel`-Einträge modelliert sind, skaliert das automatisch auf beliebig viele Fachbereiche, ohne dass die Formel angepasst werden muss.

Formel: `windowSize(level) = round(10 + (level - 1) * 1.5)`

Bewusst **nicht** Teil des ObjectBox-Schemas, sondern eine separate Balancing-Config — damit die Werte beim Playtesting angepasst werden können, ohne eine Schema-Migration auszulösen:

```dart
class DifficultyBalancing {
  static const int baseWindowSize = 10;
  static const double windowSizeStepPerLevel = 1.5;

  // wird pro SkillLevel-Eintrag aufgerufen,
  // z. B. windowSizeForLevel(skillLevel.level)
  static int windowSizeForLevel(int level) {
    return (baseWindowSize + (level - 1) * windowSizeStepPerLevel).round();
  }
}
```

Beispielwerte:

| Level | Fenstergröße |
|---|---|
| 1 | 10 |
| 2 | 12 |
| 3 | 13 |
| 4 | 15 |
| 5 | 16 |

---

## Kernsystem 5: Zuhause & Erkundung (resolved)

Der Pal hat ein **Zuhause** als Basis (`locationState = 'home'`) und kann von dort aus **Biome** (thematische Gebiete mit eigener Schwierigkeit) betreten (`locationState = 'exploring'`, `currentBiome` gesetzt).

- **Aktionstypen bleiben ein thematischer Layer über der bestehenden Task Engine** — es entstehen keine eigenständigen Spielmodi mit eigener Logik. Ob ein Kind zuhause füttert, ein Biom erkundet, ein Geheimnis lüftet oder gegen einen wilden Pal kämpft: technisch werden in allen Fällen Aufgaben aus der Task Engine gelöst, nur mit unterschiedlichem thematischem Rahmen (`Activity.activityType`)
- **`Activity`** bündelt eine Folge von Aufgaben unter einem Thema (z. B. "Erkunde Zauberwald" = 3 Aufgaben in Folge) und trackt Start/Abschluss
- **`Biome`** definiert das Gebiet selbst: Name, Schwierigkeitsstufe, Freischalt-Bedingung (`unlockMinPalLevel`)
- **Belohnung vorerst rein kosmetisch** (Erfolgs-Screen/Animation) — kein persistentes Item. Ein Item-/Inventar-Bezug auf `Activity` ist bewusst noch nicht im Schema, kommt erst mit dem Inventarsystem dazu

---

## Kernsystem 6: Charakter-Designer & Altersgruppen (resolved)

Zusätzlich zur Foto-Pipeline (Kernsystem 3) gibt es einen **Baukasten-Designer**, der zwei Mal zum Einsatz kommt:

- **Als eigener, paralleler Weg:** `sourceType = 'designer'` — das Sprite entsteht komplett aus gewählten `CharacterComponentOption`-Bauteilen (Körperform, Farbe, Augen, Accessoires), keine Foto-Pipeline nötig
- **Als Nachbearbeitung des Foto-Wegs:** `sourceType = 'photo'` mit zusätzlichen `SpriteComponentSelection`-Einträgen oben auf dem segmentierten/pixelierten Bild (z. B. Farb-Overlay, Accessoires) — stärkt die Identifikation mit dem eigenen Pal

**Geführter vs. freier Modus:** Gesteuert über `ChildProfile.ageYears` aus dem Eltern-Profil-Setup — jüngere Kinder bekommen automatisch den **geführten Modus** (`designMode = 'guided'`, reduzierte Auswahl über `CharacterComponentOption.guidedModeEligible`), ältere den **freien Modus** (`designMode = 'free'`, volle Auswahl). Die konkrete Alters-Schwelle ist noch nicht final (Platzhalter-Annahme: < 6 Jahre → geführt) und sollte im Playtesting validiert werden — analog zur `DifficultyBalancing`-Config als eigene, leicht anpassbare Konstante statt hart im Schema kodiert.

---

## Entscheidungsübersicht (Stand jetzt)

| Thema | Status |
|---|---|
| Time-Delta Cap/Leniency-Policy | ✅ Resolved — 20 % Floor, 3-Tage-Freeze, Soft Re-Entry |
| Aufgaben-Format | ✅ Resolved — Bild+Audio Standard, Text optional |
| Pal-Ersetzung vs. Sammlung alter Pets | ✅ Resolved — Sammlung |
| Persistenz-Library | ✅ Resolved — ObjectBox (Isar/Hive ausgeschlossen, beide abandoned); Drift als Fallback — **Team-Sign-off ausstehend** |
| Segmentierungsmodell | ✅ Resolved — ML Kit Subject Segmentation primär, MODNet als Fallback |
| Datenmodell (Entities, Skill-Fenster-Skalierung, SpriteAsset-Kardinalität) | ✅ Resolved — siehe Kernsystem 4 |
| Zuhause/Biome/Activity-Struktur, Aktionstypen als Task-Engine-Layer | ✅ Resolved — siehe Kernsystem 5 |
| DifficultyModel-Struktur bei mehreren Fachbereichen | ✅ Resolved — generisch über `SkillLevel`-Entity, siehe Kernsystem 4 |
| Charakter-Designer (Verhältnis zur Foto-Pipeline, geführter vs. freier Modus) | ✅ Resolved — siehe Kernsystem 6 |

---

## To-Dos / Erweiterungsideen (noch zu klären)

Struktur ist jetzt geklärt (siehe Kernsystem 4, 5 & 6); der verbleibende Punkt ist inhaltlicher Natur und braucht eine eigene Design-Session vor der Umsetzung.

1. **Weitere Aufgaben-Kategorien (Fachbereiche) — inhaltlich noch offen**
   Fachbereiche sind gesetzt: Mathematik, **Sprache** (Deutsch/Englisch), **Biologie**, **Physik**, **Musik** — weitere vorbehalten. Struktur dafür ist resolved (generisches `SkillLevel`, siehe Kernsystem 4). Inhaltlich noch offen:
   - Konkrete Progressionsstufen pro Fachbereich (analog zur Mathe-Progression Piktogramm → Abstrakt)
   - Format pro Fachbereich — Sprache z. B. mit Audio-Aussprache, Musik evtl. mit Hörbeispielen: passt das ins bestehende Bild+Audio-Format oder braucht es Format-Erweiterungen?
   - **Altersspanne:** Konzept muss durchgängig von einfachen Vorschulfragen bis zu Grundschulfragen skalieren — Progression pro Fachbereich braucht also einen deutlich breiteren Level-Bereich als ursprünglich für reine Vorschul-Mathematik angedacht

2. **Alters-Schwelle für geführten vs. freien Designer-Modus** (siehe Kernsystem 6)
   Platzhalter-Annahme < 6 Jahre → geführt ist noch nicht validiert und sollte im Playtesting geprüft werden.

---

## Nächste Schritte

1. **Team-Sign-off einholen** für den Persistenz-Wechsel weg von Isar/Hive hin zu ObjectBox
2. ~~Datenmodellierung~~ ✅ erledigt, siehe Kernsystem 4
3. Projekt-Grundstruktur (Flutter-Setup, Ordnerstruktur nach Schichtenmodell, klare Trennung Domain Core / Persistenz / UI im Hinblick auf spätere Wearable-Unterstützung)
4. ObjectBox-Setup (Entities aus Kernsystem 4 als Ausgangspunkt)
5. Prototyping der Segmentierungs-Pipeline (ML Kit zuerst, MODNet-Fallback bei Bedarf testen mit echten Kinderzeichnungen)
