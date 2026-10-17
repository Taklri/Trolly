import 'package:flutter/material.dart';

import '../models/shopping_history_entry.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyMintBorder = Color(0xFFC9E9D4);
const _textPrimary = Color(0xFF171717);
const _textSecondary = Color(0xFF616161);

class HistorySummaryScreen extends StatelessWidget {
  const HistorySummaryScreen({super.key, this.entry});

  final ShoppingHistoryEntry? entry;

  @override
  Widget build(BuildContext context) {
    Object? arguments = ModalRoute.of(context)?.settings.arguments;
    ShoppingHistoryEntry? history = entry;

    if (history == null && arguments is ShoppingHistoryEntry) {
      history = arguments;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: history == null
                  ? _buildMissingHistory(context)
                  : _buildSummary(context, history),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        key: const Key('history-summary-back'),
        onPressed: () {
          Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          foregroundColor: _textSecondary,
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.arrow_back, size: 21),
        label: const Text('Back to Home'),
      ),
    );
  }

  Widget _buildMissingHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(context),
        const SizedBox(height: 24),
        const Text(
          'History not found',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This shopping history is no longer available.',
          style: TextStyle(color: _textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, ShoppingHistoryEntry history) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(context),
          const SizedBox(height: 12),
          const Text(
            'Shopping Summary',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            history.title,
            style: const TextStyle(
              color: _trollyGreen,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(history.completedAt),
            style: const TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildProductList(history),
          const SizedBox(height: 16),
          _buildTotals(history),
        ],
      ),
    );
  }

  Widget _buildProductList(ShoppingHistoryEntry history) {
    List<Map<String, dynamic>> products = history.products ?? [];

    return ListView.separated(
      key: const Key('history-product-list'),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        Map<String, dynamic> product = products[index];
        String name = product['productName']?.toString() ?? 'Product';
        int price = (product['productPriceCentavos'] as num?)?.toInt() ?? 0;
        int quantity = (product['quantity'] as num?)?.toInt() ?? 0;
        int total = (product['totalCentavos'] as num?)?.toInt() ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatPesos(price)} × $quantity',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatPesos(total),
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotals(ShoppingHistoryEntry history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: _trollyMintBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (history.hasBudget == true &&
              history.startingBudgetCentavos != null)
            _buildAmountRow('Starting Budget', history.startingBudgetCentavos!),
          _buildAmountRow('Total Spending', history.totalCentavos),
          if (history.hasBudget == true && history.budgetLeftCentavos != null)
            _buildAmountRow('Budget Left', history.budgetLeftCentavos!),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _textSecondary, fontSize: 14),
            ),
          ),
          Text(
            _formatPesos(amount),
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPesos(int totalCentavos) {
  bool isNegative = totalCentavos < 0;
  int absoluteAmount = totalCentavos.abs();
  int pesos = absoluteAmount ~/ 100;
  int centavos = absoluteAmount % 100;
  String groupedPesos = pesos.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  String sign = isNegative ? '-' : '';

  if (absoluteAmount == 0 || centavos != 0) {
    return '$sign₱$groupedPesos.${centavos.toString().padLeft(2, '0')}';
  }
  return '$sign₱$groupedPesos';
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  DateTime localDate = date.toLocal();
  return '${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}';
}
