import 'package:flutter/material.dart';

// Austausch-Vertrag fuer die Homescreen-Hintergrund-Ebene (Feature-Spec
// "Warme Wiese"). Konkrete Szenen (aktuell PalBackgroundMeadow, spaeter z. B.
// PalBackgroundFarm) implementieren diese Basisklasse und sind damit 1:1
// austauschbar -- darueberliegende UI-Widgets (PalWidget, StatBar, Buttons)
// kennen nur diesen Typ, nicht die konkrete Szene. Muss den verfuegbaren
// Platz vollstaendig ausfuellen, damit jede Szene ohne Layout-Anpassung an
// der aufrufenden Stelle funktioniert.
abstract class HomescreenBackground extends StatelessWidget {
  const HomescreenBackground({super.key});
}
