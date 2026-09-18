import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/ingestion_controller.dart';

// Character Ingestion Pipeline (Kernsystem 3): Foto aufnehmen/auswaehlen,
// durch die Pipeline schicken, Ergebnis speichern. Bewusst ungestylt --
// Design steht fuer diesen Screen noch aus.
class CharacterIngestionScreen extends StatefulWidget {
  final int palId;

  const CharacterIngestionScreen({super.key, required this.palId});

  @override
  State<CharacterIngestionScreen> createState() => _CharacterIngestionScreenState();
}

class _CharacterIngestionScreenState extends State<CharacterIngestionScreen> {
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null || !mounted) return;

    await context.read<IngestionController>().ingestFromPath(
          palId: widget.palId,
          imagePath: file.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<IngestionController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Eigenes Pal erstellen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SingleChildScrollView statt Spacer: Fehlermeldungen (inkl.
            // technischer Details) koennen laenger sein als der Bildschirm --
            // ohne Scroll-Moeglichkeit fuehrte das zu einem Render-Overflow.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Fotografiere deine Zeichnung oder wähle ein Bild aus der Galerie.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (controller.isProcessing)
                      const CircularProgressIndicator()
                    else if (controller.lastDraft != null) ...[
                      Image.memory(
                        controller.lastDraft!.spriteImageBytes,
                        width: 128,
                        height: 128,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(height: 8),
                      const Text('Gespeichert!'),
                    ] else if (controller.error != null)
                      Text(
                        'Das hat leider nicht geklappt: ${controller.error}',
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.isProcessing ? null : () => _pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Foto aufnehmen'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.isProcessing ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Aus Galerie wählen'),
            ),
          ],
        ),
      ),
    );
  }
}
