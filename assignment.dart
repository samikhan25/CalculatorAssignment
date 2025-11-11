import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: CalculatorPage(toggleTheme: toggleTheme),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const CalculatorPage({super.key, required this.toggleTheme});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';

  void _onButtonPressed(String value) {
    setState(() {
      _display = calculate(_display, value);
    });
  }

  String calculate(String currentDisplay, String input) {
    if (input == 'AC') return '0';
    if (input == '⌫') {
      if (currentDisplay.length > 1) {
        return currentDisplay.substring(0, currentDisplay.length - 1);
      } else {
        return '0';
      }
    }

    // Percentage
    if (input == '%') {
      try {
        double value = double.parse(currentDisplay);
        return (value / 100).toString();
      } catch (e) {
        return 'Error';
      }
    }

    // Toggle sign
    if (input == '+/−') {
      try {
        double value = double.parse(currentDisplay);
        return (-value).toString();
      } catch (e) {
        return currentDisplay;
      }
    }

    if (input == '=') {
      try {
        String expression = currentDisplay
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('−', '-');
        Parser p = Parser();
        Expression exp = p.parse(expression);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        return eval.toString();
      } catch (e) {
        return 'Error';
      }
    }

    // Prevent multiple operators in a row
    if ('÷×−+'.contains(input) && currentDisplay.isNotEmpty) {
      if ('÷×−+'.contains(currentDisplay[currentDisplay.length - 1])) {
        return currentDisplay;
      }
    }

    // Append input
    if (currentDisplay == '0' && input != '.') return input;
    return currentDisplay + input;
  }

  Widget buildButton(String text,
      {Color? color, Color textColor = Colors.white}) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[800],
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 24, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['AC', '÷', '×', '⌫'],
      ['7', '8', '9', '−'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '%', '+/−'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                _display,
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: buttons.length * 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 4;
                  int col = index % 4;
                  String text = buttons[row][col];
                  Color? btnColor;
                  if ('÷×−+'.contains(text)) btnColor = Colors.orange;
                  if (text == 'AC') btnColor = Colors.red;
                  if (text == '=') btnColor = Colors.green;
                  if (text == '%') btnColor = Colors.orange;
                  if (text == '+/−') btnColor = Colors.blueGrey;

                  return buildButton(text, color: btnColor);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
