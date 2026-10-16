import 'app_preferences.dart';

class ShoppingHistoryEntry {
  const ShoppingHistoryEntry({
    required this.id,
    required this.completedAt,
    required this.title,
    required this.totalCentavos,
    this.currencyCode = 'PHP',
  });

  final String id;
  final DateTime completedAt;
  final String title;
  final int totalCentavos;
  final String currencyCode;

  TrollyCurrency get currency => trollyCurrencyFromCode(currencyCode);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'title': title,
      'totalCentavos': totalCentavos,
      'currencyCode': currency.code,
    };
  }

  factory ShoppingHistoryEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final completedAt = json['completedAt'];
    final title = json['title'];
    final totalCentavos = json['totalCentavos'];
    final currencyCode = json['currencyCode'];

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
      currencyCode: trollyCurrencyFromCode(
        currencyCode is String ? currencyCode : null,
      ).code,
    );
  }
}
