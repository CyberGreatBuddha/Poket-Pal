import 'package:flutter/material.dart';

// Farbpalette fuer den Homescreen "Warme Wiese" (Zwischenloesung, siehe
// Feature-Spec). Warme Koralle/Amber-Toene, kraeftig und kontrastreich fuer
// Vorschulkinder. Nur fuer diesen Screen -- kein projektweites Farbschema
// (das wird separat entwickelt).
class MeadowPalette {
  static const sky = Color(0xFFFAECE7);
  static const palBody = Color(0xFFD85A30);
  static const ground = Color(0xFFF0997B);
  // Spec nennt zwei Toene fuer hellen Grund: primaer fuer Ueberschriften/
  // wichtigen Text, sekundaer fuer weniger betonten Text.
  static const textOnLightPrimary = Color(0xFF4A1B0C);
  static const textOnLightSecondary = Color(0xFF712B13);
  static const textOnDark = Color(0xFFFAECE7);
}
