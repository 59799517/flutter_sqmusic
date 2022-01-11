import 'package:flutter/material.dart';

///2022/1/7
///
class HollowWordWidget extends StatelessWidget {
  final Color color;
  final String text;
  final double fontSize;
  final Paint painter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  HollowWordWidget(this.text, {this.color = Colors.black, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                foreground: painter..color = color,
                fontSize: fontSize,
              )),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        return CustomPaint(
          painter: HollowWordPainter(textPainter),
          size: textPainter.size,
        );
      },
    );
  }
}

class HollowWordPainter extends CustomPainter {
  TextPainter textPainter;

  HollowWordPainter(this.textPainter);

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}