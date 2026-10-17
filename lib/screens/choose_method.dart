import 'package:flutter/material.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyOrange = Color(0xFFFF9D00);
const _trollyCream = Color(0xFFFFF2DC);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _trollyDisabled = Color(0xFFD6D6D6);

class ChooseMethodScreen extends StatelessWidget {
  const ChooseMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double pagePadding = MediaQuery.sizeOf(context).width < 360 ? 16 : 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pagePadding, 24, pagePadding, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 52,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _trollyGreen,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Choose',
                    style: TextStyle(
                      color: _trollyText,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Method',
                    style: TextStyle(
                      color: _trollyGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'How do you want to shop today?',
                    style: TextStyle(
                      color: _trollySecondaryText,
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                methodCard(
                                  key: const Key('choose-on-the-go'),
                                  title: 'On The Go Shopping',
                                  description:
                                      'Track your expenses live while you shop',
                                  steps: const [
                                    'Set Budget',
                                    'List Products',
                                    'Get exact amount before paying over the counter',
                                  ],
                                  backgroundColor: _trollyMint,
                                  borderColor: _trollyGreen,
                                  stepColor: _trollyGreen,
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/on-the-go');
                                  },
                                ),
                                const SizedBox(height: 20),
                                Semantics(
                                  label: 'Use Grocery List, unavailable',
                                  button: true,
                                  enabled: false,
                                  child: ExcludeSemantics(
                                    child: methodCard(
                                      key: const Key('choose-grocery-list'),
                                      title: 'Use Grocery List',
                                      description:
                                          'Create and manage your grocery lists.',
                                      steps: const [
                                        'Use your created List',
                                        'Set Budget',
                                        'Get exact amount before paying over the counter',
                                      ],
                                      backgroundColor: _trollyCream,
                                      borderColor: _trollyOrange,
                                      stepColor: _trollyOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('choose-cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _trollyDisabled,
                        foregroundColor: _trollyText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget methodCard({
    required Key key,
    required String title,
    required String description,
    required List<String> steps,
    required Color backgroundColor,
    required Color borderColor,
    required Color stepColor,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      key: key,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor,
        foregroundColor: _trollyText,
        disabledForegroundColor: _trollyText,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _trollyText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _trollySecondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: stepColor,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: const TextStyle(
                        color: _trollyText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
