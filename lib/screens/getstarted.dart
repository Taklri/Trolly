import 'package:flutter/material.dart';

import '../services/user_preferences.dart';
import '../theme/trolly_colors.dart';
import 'home.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key, required this.userPreferences});

  final UserPreferences userPreferences;

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  bool _isSaving = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleNameChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_handleNameChanged)
      ..dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleNameChanged() {
    if (_nameError != null && _nameController.text.trim().isNotEmpty) {
      setState(() {
        _nameError = null;
      });
    }
  }

  Future<void> _getStarted() async {
    final name = _nameController.text.trim();
    if (_isSaving) return;

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name.';
      });
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.userPreferences.saveName(name);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => HomeScreen(userName: name)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not save your name. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = (constraints.maxWidth * 0.73)
                .clamp(175.0, 215.0)
                .toDouble();
            final contentWidth = (constraints.maxWidth * 0.83)
                .clamp(224.0, 320.0)
                .toDouble();
            final topSpacing = (constraints.maxHeight * 0.16)
                .clamp(72.0, 104.0)
                .toDouble();
            final brandingToFormSpacing = (constraints.maxHeight * 0.08)
                .clamp(34.0, 50.0)
                .toDouble();
            final formToButtonSpacing = (constraints.maxHeight * 0.14)
                .clamp(56.0, 86.0)
                .toDouble();

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 28).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    Image.asset(
                      'assets/images/trolly.jpg',
                      width: logoWidth,
                      fit: BoxFit.contain,
                      semanticLabel: 'Trolly grocery cart',
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'TROLLY',
                      style: TextStyle(
                        color: kTrollyGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: brandingToFormSpacing),
                    SizedBox(
                      width: contentWidth,
                      child: const Text(
                        'Tell us your name',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: contentWidth,
                      height: _nameError == null ? 38 : 58,
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _getStarted(),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(focused: true),
                          errorText: _nameError,
                          errorStyle: const TextStyle(
                            color: Color(0xFFE25252),
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: formToButtonSpacing),
                    SizedBox(
                      width: contentWidth,
                      height: 35,
                      child: FilledButton(
                        onPressed: _getStarted,
                        style: FilledButton.styleFrom(
                          backgroundColor: kTrollyGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          _isSaving ? 'Saving...' : "Let's Get Started",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder({bool focused = false}) {
    final borderColor = _nameError == null
        ? (focused ? kTrollyGreen : const Color(0xFFCCCCCC))
        : const Color(0xFFE25252);

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor, width: focused ? 1.5 : 1),
    );
  }
}
