import 'package:flutter/material.dart';

// Kleinerer Button unten rechts, gleiche teiltransparente Kartenflaeche wie
// StatBar (Feature-Spec Abschnitt 1). Kein Inventarsystem im Konzept bisher
// umgesetzt (siehe projektkonzept.md, "Inventarsystem" ist spaetere Phase) --
// zeigt daher vorerst nur einen Hinweis statt echter Funktionalitaet.
class InventoryButton extends StatelessWidget {
  const InventoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.backpack),
        tooltip: 'Inventar',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventar kommt bald')),
          );
        },
      ),
    );
  }
}
