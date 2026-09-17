// Generischer, typisierter Zugriff auf die noch nicht abschliessend
// definierten "weiteren Eigenschaften" eines Pals (z. B. Persoenlichkeit,
// Vorlieben, kosmetische Merkmale -- kommt spaeter). Werte werden intern als
// String gehalten (persistenzseitig ein simples key/value-Paar, siehe
// PalAttribute-Entity) und hier typisiert interpretiert, damit Aufrufer nicht
// selbst parsen muessen.
class PalAttributes {
  final Map<String, String> _values;

  const PalAttributes._(this._values);

  factory PalAttributes.empty() => const PalAttributes._({});

  factory PalAttributes.fromMap(Map<String, String> values) =>
      PalAttributes._(Map.unmodifiable(values));

  String? getString(String key) => _values[key];

  int? getInt(String key) {
    final raw = _values[key];
    return raw == null ? null : int.tryParse(raw);
  }

  double? getDouble(String key) {
    final raw = _values[key];
    return raw == null ? null : double.tryParse(raw);
  }

  bool? getBool(String key) {
    final raw = _values[key];
    return raw == null ? null : raw == 'true';
  }

  PalAttributes withValue(String key, Object value) {
    final updated = Map<String, String>.from(_values)..[key] = value.toString();
    return PalAttributes._(Map.unmodifiable(updated));
  }

  PalAttributes withoutValue(String key) {
    final updated = Map<String, String>.from(_values)..remove(key);
    return PalAttributes._(Map.unmodifiable(updated));
  }

  Map<String, String> asMap() => _values;
}
