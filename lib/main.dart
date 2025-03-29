import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  bool _isNewExpression = true; 

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _output = "0";
        _isNewExpression = true;  
      } else if (buttonText == "=") {
        _calculateResult();
        _isNewExpression = true;
      } else if (buttonText == "abs") {
        double num = double.parse(_output);
        _output = (num.abs()).toString();
        _isNewExpression = false;
      } else if (buttonText == "ln") {
        double num = double.parse(_output);
        if (num > 0) {
          _output = (log(num)).toString();
        } else {
          _output = "Ошибка";
        }
        _isNewExpression = false;
      } else {
        if (_isNewExpression) {
          _output = buttonText;
          _isNewExpression = false;
        } else {
          if (_output == "0" && buttonText != ".") {
            _output = buttonText;
          } else {
            _output += buttonText;
          }
        }
      }
    });
  }

  void _calculateResult() {
    try {
      if (_output.endsWith('.')) {
        setState(() {
          _output = "Ошибка";
        });
        return;
      }

      RegExp decimalRegExp = RegExp(
        r'(\d+)\.\s*[\+\-\*\/]\s*(\d+)|(\d+)\.\d*\.\d*',
      );
      if (decimalRegExp.hasMatch(_output)) {
        setState(() {
          _output = "Ошибка";
        });
        return;
      }

      RegExp regExp = RegExp(r'(\d+)\s*-\s*[\+\-\*\/]\s*(\d+)');
      if (regExp.hasMatch(_output)) {
        setState(() {
          _output = "Ошибка";
        });
        return;
      }

      Parser p = Parser();
      String expression = _output.replaceAll('×', '*').replaceAll('÷', '/');
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _output = eval.toString();
        _isNewExpression = true; 
      });
    } catch (e) {
      setState(() {
        _output = "Ошибка";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Калькулятор"),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DocumentationScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF66BB6A),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Text(
                  _output,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Divider(height: 1),
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(10),
                children: [
                  _buildButton("ln"),
                  _buildButton("abs"),
                  _buildButton("^"),
                  _buildButton("÷"),
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("×"),
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("-"),
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("+"),
                  _buildButton("0"),
                  _buildButton("."),
                  _buildButton("AC"),
                  _buildButton("="),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7AB97D),
          foregroundColor: Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFF45A84A), width: 2),
          ),
          padding: EdgeInsets.all(20),
        ),
        onPressed: () => _onButtonPressed(buttonText),
        child: Text(buttonText, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class DocumentationScreen extends StatelessWidget {
  Future<String> loadMarkdown() async {
    return await rootBundle.loadString('assets/README.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Документация')),
      body: FutureBuilder<String>(
        future: loadMarkdown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки документации'));
          } else {
            return Markdown(data: snapshot.data!);
          }
        },
      ),
    );
  }
}
