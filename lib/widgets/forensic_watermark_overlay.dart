import 'dart:math' as math;
import 'package:flutter/material.dart';

class ForensicWatermarkOverlay extends StatelessWidget {
  final Widget child;
  final String viewerIdentifier; // e.g. "Steadfast Anchor #402"
  final String viewerUid;

  const ForensicWatermarkOverlay({
    super.key,
    required this.child,
    required this.viewerIdentifier,
    required this.viewerUid,
  });

  @override
  Widget build(BuildContext context) {
    final String timestamp = DateTime.now().toIso8601String().substring(0, 16);
    final String uidHash = viewerUid.length > 8 ? viewerUid.substring(0, 8) : viewerUid;
    final String watermarkText = "DIM VAULT • $viewerIdentifier • ID:$uidHash • $timestamp";

    return Stack(
      children: [
        // 1. Primary Protected Content
        child,

        // 2. Non-interactive Forensic Watermark Canvas
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WatermarkPainter(watermarkText: watermarkText),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String watermarkText;

  _WatermarkPainter({required this.watermarkText});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: const Color(0xFFD4AF37).withOpacity(0.045), // Subtle gold stencil
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );

    final textSpan = TextSpan(text: watermarkText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const double stepX = 260.0;
    const double stepY = 120.0;

    canvas.save();
    // Rotate canvas by -25 degrees for classic forensic angle
    canvas.rotate(-math.pi / 7.2);

    for (double x = -size.width; x < size.width * 2; x += stepX) {
      for (double y = -size.height; y < size.height * 2; y += stepY) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}