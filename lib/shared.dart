import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const EdgeInsets topPadding = EdgeInsets.only(top: 800 * 0.5 * 0.75);

EdgeInsets customTopPadding(double factor) {
  return EdgeInsets.only(top: 800 * 0.5 * factor);
}

EdgeInsets customBottomPadding(double factor) {
  return EdgeInsets.only(bottom: 800 * 0.5 * factor);
}

EdgeInsets customLeftPadding(double factor) {
  return EdgeInsets.only(left: 480 * 0.5 * factor);
}

EdgeInsets customRightPadding(double factor) {
  return EdgeInsets.only(right: 480 * 0.5 * factor);
}

SnackBar customSnackBar(String text) {
  return SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: 45),
  );
}

class CustomTextButton extends StatelessWidget {
  late Color color1;
  late Color color2;
  late String text;
  late Color textColor;
  late double fontsize;
  late double radius;
  late double width;
  late double height;

  CustomTextButton(
      {super.key,
      required this.color1,
      required this.color2,
      required this.text,
      required this.textColor,
      required this.fontsize,
      required this.radius,
      required this.width,
      required this.height});

  @override
  Widget build(Object context) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        gradient: LinearGradient(
          colors: [
            color1,
            color2,
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.resolveWith(
              (states) => Size(width, height)),
        ),
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontsize,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class MyTextInputFormatter extends TextInputFormatter {
  bool _makingList = false;
  int _cursorOffset = 0;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textToReturn = newValue.text;
    _cursorOffset = newValue.selection.extentOffset;

    if ((newValue.text.endsWith('\n-') ||
            (oldValue.text.isEmpty && newValue.text.endsWith('-'))) &&
        _makingList == false) {
      _makingList = true;
      textToReturn = textToReturn.replaceRange(
          textToReturn.length - 1, textToReturn.length, ' • ');
      _cursorOffset += 2;
    } else if (_makingList == true) {
      if (textToReturn.endsWith('\n • \n')) {
        _makingList = false;
        textToReturn = textToReturn.replaceRange(
            textToReturn.length - 4, textToReturn.length, '\n');
        _cursorOffset -= 3;
      } else if (_makingList == true && textToReturn.endsWith('\n')) {
        textToReturn += ' • ';
        _cursorOffset += 3;
      } else if (oldValue.text.endsWith('•') && !newValue.text.endsWith('•')) {
        _makingList = false;
        textToReturn = newValue.text;
        _cursorOffset = newValue.selection.extentOffset;
      }
    }

    return TextEditingValue(text: textToReturn);
  }

  bool getMakingList() {
    return _makingList;
  }

  void setMakingList(bool newValue) {
    _makingList = newValue;
  }

  int getCursorOffset() {
    return _cursorOffset;
  }
}

class TitleTextInputFormatter extends TextInputFormatter {
  int _cursorOffset = 0;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String textToReturn = newValue.text;
    _cursorOffset = newValue.selection.extentOffset;
    if (oldValue.text.contains('Title (optional)')) {
      if (oldValue.text.length > newValue.text.length) {
        textToReturn = '';
        _cursorOffset = 1;
      } else {
        for (var i = 0; i < oldValue.text.length; i++) {
          if (oldValue.text.codeUnitAt(i) != newValue.text.codeUnitAt(i)) {
            textToReturn = String.fromCharCode(newValue.text.codeUnitAt(i));
            _cursorOffset = 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(text: textToReturn);
  }

  int getCursorOffset() {
    return _cursorOffset;
  }
}
