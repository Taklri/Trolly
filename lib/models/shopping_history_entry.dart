class ShoppingHistoryEntry {
  const ShoppingHistoryEntry({
    required this.id,
    required this.completedAt,
    required this.title,
    required this.totalCentavos,
  });

  final String id;
  final DateTime completedAt;
  final String title;
  final int totalCentavos;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'title': title,
      'totalCentavos': totalCentavos,
    };
  }

  factory ShoppingHistoryEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final completedAt = json['completedAt'];
    final title = json['title'];
    final totalCentavos = json['totalCentavos'];

    if (id is! String ||
        completedAt is! String ||
        title is! String ||
        totalCentavos is! num) {
      throw const FormatException('Invalid shopping history entry.');
    }

    return ShoppingHistoryEntry(
      id: id,
      completedAt: DateTime.parse(completedAt),
      title: title,
      totalCentavos: totalCentavos.toInt(),
    );
  }
}
