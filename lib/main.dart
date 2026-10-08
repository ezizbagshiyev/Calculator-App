import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorPage(
        isDark: _isDark,
        onThemeChanged: (value) {
          setState(() {
            _isDark = value;
          });
        },
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const CalculatorPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';

  double? _firstOperand;
  String? _operator;

  bool _waitingForSecondOperand = false;
  bool _hasError = false;
  bool _justCalculated = false;

  // ============================================================
  // NUMBER INPUT
  // ============================================================

  void _inputDigit(String digit) {
    setState(() {
      if (_hasError) {
        _clearAllInternal();
      }

      if (_justCalculated) {
        _display = digit;
        _firstOperand = null;
        _operator = null;
        _justCalculated = false;
        return;
      }

      if (_waitingForSecondOperand) {
        _display = digit;
        _waitingForSecondOperand = false;
        return;
      }

      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  // ============================================================
  // DECIMAL POINT
  //
  // This is not required for undergraduate, but makes the
  // calculator more complete and prevents crashes with decimals.
  // ============================================================

  void _inputDecimal() {
    setState(() {
      if (_hasError) {
        _clearAllInternal();
      }

      if (_justCalculated) {
        _display = '0.';
        _firstOperand = null;
        _operator = null;
        _justCalculated = false;
        return;
      }

      if (_waitingForSecondOperand) {
        _display = '0.';
        _waitingForSecondOperand = false;
        return;
      }

      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  // ============================================================
  // OPERATOR INPUT
  // ============================================================

  void _inputOperator(String operator) {
    setState(() {
      if (_hasError) {
        return;
      }

      final input = double.tryParse(_display);

      if (input == null) {
        _showError('Enter a valid number first.');
        return;
      }

      // Allows changing the operator before entering
      // the second operand.
      if (_waitingForSecondOperand && _firstOperand != null) {
        _operator = operator;
        return;
      }

      if (_firstOperand != null && _operator != null) {
        final result = _calculate(_firstOperand!, input, _operator!);

        if (result == null) {
          return;
        }

        _display = _formatNumber(result);
        _firstOperand = result;
      } else {
        _firstOperand = input;
      }

      _operator = operator;
      _waitingForSecondOperand = true;
      _justCalculated = false;
    });
  }

  // ============================================================
  // EQUALS
  // ============================================================

  void _equals() {
    setState(() {
      if (_hasError) {
        return;
      }

      if (_firstOperand == null ||
          _operator == null ||
          _waitingForSecondOperand) {
        _showError('Enter a second number before pressing =.');
        return;
      }

      final secondOperand = double.tryParse(_display);

      if (secondOperand == null) {
        _showError('Enter a valid second number.');
        return;
      }

      final result = _calculate(_firstOperand!, secondOperand, _operator!);

      if (result == null) {
        return;
      }

      _display = _formatNumber(result);
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
      _justCalculated = true;
    });
  }

  // ============================================================
  // CALCULATION
  // ============================================================

  double? _calculate(double first, double second, String operator) {
    switch (operator) {
      case '+':
        return first + second;

      case '-':
        return first - second;

      case '×':
        return first * second;

      case '÷':
        if (second == 0) {
          _showError('Cannot divide by zero. Press AC to recover.');
          return null;
        }

        return first / second;

      default:
        _showError('Unknown operation. Press AC to recover.');
        return null;
    }
  }

  // ============================================================
  // PERCENTAGE
  //
  // Examples:
  //
  // 50 %       -> 0.5
  // 200 + 10 % -> 220
  // 200 - 10 % -> 180
  // 200 × 10 % -> 20
  // 200 ÷ 10 % -> 2000
  // ============================================================

  void _percentage() {
    setState(() {
      if (_hasError) {
        return;
      }

      final value = double.tryParse(_display);

      if (value == null) {
        _showError('Enter a valid number before using %.');
        return;
      }

      if (_firstOperand != null &&
          _operator != null &&
          !_waitingForSecondOperand) {
        double percentageValue;

        if (_operator == '+' || _operator == '-') {
          percentageValue = _firstOperand! * value / 100;
        } else {
          percentageValue = value / 100;
        }

        _display = _formatNumber(percentageValue);
      } else {
        _display = _formatNumber(value / 100);
      }
    });
  }

  // ============================================================
  // POSITIVE / NEGATIVE
  // ============================================================

  void _toggleSign() {
    setState(() {
      if (_hasError) {
        return;
      }

      if (_display == '0' || _display == '0.0') {
        return;
      }

      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  // ============================================================
  // CLEAR ENTRY
  //
  // C = Clear current entry only.
  // ============================================================

  void _clearEntry() {
    setState(() {
      _display = '0';
      _hasError = false;
      _justCalculated = false;

      if (_waitingForSecondOperand) {
        _waitingForSecondOperand = true;
      }
    });
  }

  // ============================================================
  // ALL CLEAR
  //
  // AC = reset EVERYTHING.
  // ============================================================

  void _clearAllInternal() {
    _display = '0';
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
    _hasError = false;
    _justCalculated = false;
  }

  void _clearAll() {
    setState(() {
      _clearAllInternal();
    });
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  void _showError(String message) {
    _hasError = true;
    _display = 'Error';

    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
    _justCalculated = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'AC', onPressed: _clearAll),
          ),
        );
    });
  }

  // ============================================================
  // NUMBER FORMATTING
  // ============================================================

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    if (value == 0) {
      return '0';
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    String result = value.toStringAsPrecision(12);

    if (result.contains('.')) {
      result = result.replaceFirst(RegExp(r'0+$'), '');

      result = result.replaceFirst(RegExp(r'\.$'), '');
    }

    return result;
  }

  // ============================================================
  // BUTTON COLORS
  // ============================================================

  Color _buttonColor(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;

    if (label == 'AC') {
      return scheme.errorContainer;
    }

    if (label == 'C') {
      return scheme.secondaryContainer;
    }

    if (label == '%' || label == '+/-') {
      return scheme.tertiaryContainer;
    }

    if (['+', '-', '×', '÷', '='].contains(label)) {
      return scheme.primaryContainer;
    }

    return scheme.surfaceContainerHighest;
  }

  // ============================================================
  // ACCESSIBILITY LABELS
  // ============================================================

  String _semanticLabel(String label) {
    switch (label) {
      case 'AC':
        return 'All clear';

      case 'C':
        return 'Clear entry';

      case '%':
        return 'Percentage';

      case '+/-':
        return 'Positive or negative';

      case '×':
        return 'Multiply';

      case '÷':
        return 'Divide';

      case '+':
        return 'Add';

      case '-':
        return 'Subtract';

      case '=':
        return 'Equals';

      case '.':
        return 'Decimal point';

      default:
        return 'Number $label';
    }
  }

  // ============================================================
  // CALCULATOR BUTTON
  // ============================================================

  Widget _button(String label) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Semantics(
        button: true,
        label: _semanticLabel(label),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _buttonColor(context, label),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            splashFactory: InkSparkle.splashFactory,
          ),
          onPressed: () {
            switch (label) {
              case 'AC':
                _clearAll();
                break;

              case 'C':
                _clearEntry();
                break;

              case '%':
                _percentage();
                break;

              case '+/-':
                _toggleSign();
                break;

              case '=':
                _equals();
                break;

              case '.':
                _inputDecimal();
                break;

              case '+':
              case '-':
              case '×':
              case '÷':
                _inputOperator(label);
                break;

              default:
                _inputDigit(label);
            }
          },
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode_outlined, size: 19),

              // IMPORTANT:
              // Semantics wraps Switch because the installed
              // Flutter version does not support semanticLabel
              // directly on Switch.
              Semantics(
                label: 'Toggle light and dark theme',
                toggled: widget.isDark,
                child: Switch(
                  value: widget.isDark,
                  onChanged: widget.onThemeChanged,
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.dark_mode_outlined, size: 19),
              ),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ==================================================
                  // DISPLAY
                  // ==================================================

                  Expanded(
                    flex: 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _display,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w500,
                            color: _hasError
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // BUTTON GRID
                  // ==================================================
                  Expanded(
                    flex: 5,
                    child: GridView.count(
                      crossAxisCount: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Row 1
                        _button('AC'),
                        _button('C'),
                        _button('%'),
                        _button('÷'),

                        // Row 2
                        _button('7'),
                        _button('8'),
                        _button('9'),
                        _button('×'),

                        // Row 3
                        _button('4'),
                        _button('5'),
                        _button('6'),
                        _button('-'),

                        // Row 4
                        _button('1'),
                        _button('2'),
                        _button('3'),
                        _button('+'),

                        // Row 5
                        _button('+/-'),
                        _button('0'),
                        _button('.'),
                        _button('='),
                      ],
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
}
