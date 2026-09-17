// Leniency-Policy (resolved): sanfter Wiedereinstieg statt Bestrafung durch
// stark abgefallene Werte -- eine kurze, freundliche Sequenz aus 1-2 leichten
// Aufgaben fuehrt zurueck ins Spiel.
class SoftReEntryPlan {
  final int easyTaskCount;

  const SoftReEntryPlan({required this.easyTaskCount});

  factory SoftReEntryPlan.standard() => const SoftReEntryPlan(easyTaskCount: 2);
}
