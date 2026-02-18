import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;
  final bool horizontalLayout;

  const AppLogo({
    super.key,
    this.size = 150,
    this.showText = true,
    this.textColor,
    this.horizontalLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? 
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C5F5F) // Ciemny niebiesko-zielony dla dark mode
            : const Color(0xFF1A4A4A)); // Ciemny niebiesko-zielony dla light mode

    if (horizontalLayout) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: LogoPainter(),
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'łatwa',
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  'Forma',
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: LogoPainter(),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 24),
          Text(
            'Łatwa',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
              letterSpacing: 1.2,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            'Forma',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
              letterSpacing: 1.2,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Gradient od jasnego zielonego na górze do ciemniejszego zielonego/teal na dole
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF66BB6A), // Jasny zielony (góra)
        const Color(0xFF4CAF50), // Średni zielony
        const Color(0xFF00897B), // Ciemny zielony/teal (dół)
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Głowa - koło
    final headRadius = size.width * 0.15;
    final headCenterY = centerY - size.height * 0.15;
    
    paint.shader = gradient.createShader(
      Rect.fromCircle(
        center: Offset(centerX, headCenterY),
        radius: headRadius,
      ),
    );
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX, headCenterY),
      headRadius,
      paint,
    );

    // Tułów - zaokrąglony prostokąt (szeroki u góry, zwężający się ku dołowi)
    final torsoWidth = size.width * 0.5;
    final torsoHeight = size.height * 0.4;
    final torsoTop = headCenterY + headRadius;
    final torsoLeft = centerX - torsoWidth / 2;
    final borderRadius = 20.0;

    paint.shader = gradient.createShader(
      Rect.fromLTWH(torsoLeft, torsoTop, torsoWidth, torsoHeight),
    );
    
    // Tułów z zaokrąglonymi rogami
    final torsoPath = Path()
      ..moveTo(torsoLeft + borderRadius, torsoTop)
      ..lineTo(torsoLeft + torsoWidth - borderRadius, torsoTop)
      ..quadraticBezierTo(
        torsoLeft + torsoWidth,
        torsoTop,
        torsoLeft + torsoWidth,
        torsoTop + borderRadius,
      )
      ..lineTo(torsoLeft + torsoWidth, torsoTop + torsoHeight - borderRadius)
      ..quadraticBezierTo(
        torsoLeft + torsoWidth,
        torsoTop + torsoHeight,
        torsoLeft + torsoWidth - borderRadius,
        torsoTop + torsoHeight,
      )
      ..lineTo(torsoLeft + borderRadius, torsoTop + torsoHeight)
      ..quadraticBezierTo(
        torsoLeft,
        torsoTop + torsoHeight,
        torsoLeft,
        torsoTop + torsoHeight - borderRadius,
      )
      ..lineTo(torsoLeft, torsoTop + borderRadius)
      ..quadraticBezierTo(
        torsoLeft,
        torsoTop,
        torsoLeft + borderRadius,
        torsoTop,
      )
      ..close();

    canvas.drawPath(torsoPath, paint);

    // Checkmark (ptaszek) w tułowiu - biały, gruby
    paint.shader = null;
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.08;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;

    final checkmarkStartX = centerX - torsoWidth * 0.15;
    final checkmarkStartY = torsoTop + torsoHeight * 0.35;
    final checkmarkMiddleX = centerX - torsoWidth * 0.05;
    final checkmarkMiddleY = torsoTop + torsoHeight * 0.5;
    final checkmarkEndX = centerX + torsoWidth * 0.2;
    final checkmarkEndY = torsoTop + torsoHeight * 0.25;

    final checkmarkPath = Path()
      ..moveTo(checkmarkStartX, checkmarkStartY)
      ..lineTo(checkmarkMiddleX, checkmarkMiddleY)
      ..lineTo(checkmarkEndX, checkmarkEndY);

    canvas.drawPath(checkmarkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
