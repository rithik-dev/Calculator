import 'package:flutter/material.dart';

void main() => runApp(MyCalculatorApp());

class MyCalculatorApp extends StatefulWidget {
  @override
  _MyCalculatorAppState createState() => _MyCalculatorAppState();
}

class _MyCalculatorAppState extends State<MyCalculatorApp> {
  String expression = '';

  final Color appBarColor = Colors.black38;
  final Color operatorBgColor = Colors.orange;
  final Color bgColor = Colors.black;
  final Color expressionTextColor = Colors.white;
  final Color backspaceColor = Colors.cyanAccent;

  String slice(String subject, [int start = 0, int end]) {
    if (subject is! String) {
      return '';
    }

    int _realEnd;
    int _realStart = start < 0 ? subject.length + start : start;
    if (end is! int) {
      _realEnd = subject.length;
    } else {
      _realEnd = end < 0 ? subject.length + end : end;
    }

    return subject.substring(_realStart, _realEnd);
  }

  bool checkIfOperator(String op) {
    var operators = new List(4);
    operators = ['÷', '×', '+', '-'];

    if (operators.contains(op)) {
      return true;
    } else {
      return false;
    }
  }

  String evaluate(String expression) {
    List operators = ['÷', '×', '-', '+'];

    var expressionList = new List();

    String tempNum = '';

    for (int i = 0; i < expression.length; i++) {
      if (operators.contains(expression[i])) {
        if (tempNum != '') expressionList.add(tempNum);
        expressionList.add(expression[i]);
        tempNum = '';
      } else {
        tempNum += expression[i];
      }
    }
    expressionList.add(tempNum); // adding last number

    int expressionListLen = expressionList.length;

    int i;

    for (String operation in operators) {
      i = 0;
      while (i < expressionListLen) {
        if (expressionListLen == 1) {
          break;
        }

        if (operation == '-') {
          // replacing [5,-,6] with [5,+,-6]
          for (int x = 0; x < expressionListLen; x++) {
            if (expressionList[x] == '-') {
              expressionList[x] = '+';
              expressionList[x + 1] = '-' + expressionList[x + 1];
            }
          }

          // removing + sign from start if any
          if (expressionList[0] == '+') {
            expressionList.removeAt(0);
          }
        }

        expressionListLen = expressionList.length;

        if (expressionList[i] == operation) {
          dynamic num1 = expressionList[i - 1];
          dynamic num2 = expressionList[i + 1];
          dynamic solvedExp;

          // if num is decimal then double.parse else int.parse
          num1 = num1.contains('.') ? double.parse(num1) : int.parse(num1);
          num2 = num2.contains('.') ? double.parse(num2) : int.parse(num2);

          switch (operation) {
            case '+':
              solvedExp = num1 + num2;
              break;
            case '-':
              solvedExp = num1 - num2;
              break;
            case '×':
              solvedExp = num1 * num2;
              break;
            case '÷':
              solvedExp = num1 / num2;
              break;
          }
          expressionList.replaceRange(i - 1, i + 2, [solvedExp.toString()]);

          expressionListLen = expressionList.length;
          i = 0;
        }
        i++;
      }
    }

    // if number is of form 55.0 .. then removing zero
    dynamic answer = expressionList[0];

    if (answer.contains('.')) {
      // if answer contains decimal point
      int index = answer.indexOf('.');
      dynamic afterDecimal = slice(answer, index + 1, answer.length);

      if (int.parse(afterDecimal) == 0) {
        answer = slice(answer, 0, index);
      } else {
        // if afterDecimal part is way too big like 7.266666666666667

        int answerLen = answer.length;
        int decimalLen = afterDecimal.length;

        int precision = 5; // no of digits after decimal point
        if (decimalLen > precision) {
          int sliceEnd = answerLen - decimalLen + precision;
          answer = slice(answer, 0, sliceEnd);
        }
      }
    }

    print("($expression) = $answer");

    return answer;
  }

  Expanded getButton(String text,
      {int flexValue: 1,
      Color buttonTextColor: Colors.white,
      Color buttonBgColor: Colors.blueGrey}) {
    return Expanded(
      flex: flexValue,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RaisedButton(
          onPressed: () {
            setState(() {
              switch (text) {
                case 'AC': // clear
                  expression = '';
                  break;

                case '<': // backspace
                  expression = slice(expression, 0, -1);
                  break;

                case '.':
                  int numberOfOperators = 0;
                  int decimalsInExpression = 0;

                  for (int i = 0; i < expression.length; i++) {
                    if (checkIfOperator(expression[i])) {
                      numberOfOperators++;
                    } else if (expression[i] == '.') {
                      decimalsInExpression++;
                    }
                  }
                  int allowedDecimalPoints = numberOfOperators + 1;

                  if (decimalsInExpression < allowedDecimalPoints) {
                    expression += '.';
                  }
                  break;

                case '=':
                  expression = evaluate(expression);
                  break;

                default:
                  if (checkIfOperator(text)) {
                    // check if last element of expression is operator .. if yes replace the operator else append
                    if (expression.length >= 1) {
                      String lastElement = slice(expression, -1);
                      if (checkIfOperator(lastElement)) {
                        expression = slice(expression, 0, -1);
                        expression += text;
                      } else {
                        expression += text;
                      }
                      // only + or - can be in the starting of an expression
                    } else if (text == '+' || text == '-') expression += text;
                  }
                  // if 'text' is a number
                  else {
                    expression += text;
                  }
                  break;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              text,
              style: TextStyle(
                color: buttonTextColor,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          color: buttonBgColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Center(
            child: Text('Calculator'),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                expression,
                style: TextStyle(
                  color: expressionTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 50.0,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getButton('AC',
                      flexValue: 2,
                      buttonTextColor: bgColor,
                      buttonBgColor: backspaceColor),
                  getButton('<',
                      buttonTextColor: bgColor, buttonBgColor: backspaceColor),
                  getButton('÷', buttonBgColor: operatorBgColor)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getButton('7'),
                  getButton('8'),
                  getButton('9'),
                  getButton('×', buttonBgColor: operatorBgColor)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getButton('4'),
                  getButton('5'),
                  getButton('6'),
                  getButton('-', buttonBgColor: operatorBgColor)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getButton('1'),
                  getButton('2'),
                  getButton('3'),
                  getButton('+', buttonBgColor: operatorBgColor)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  getButton('0', flexValue: 2),
                  getButton('.'),
                  getButton('=', buttonBgColor: operatorBgColor)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
