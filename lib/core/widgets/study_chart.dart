import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StudyLineChart extends StatefulWidget {
  final List<int> data;
  final double height;
  final Color color;

  const StudyLineChart({
    super.key,
    required this.data,
    this.height = 180,
    this.color = AppColors.primaryTeal,
  });

  @override
  State<StudyLineChart> createState() => _StudyLineChartState();
}

class _StudyLineChartState extends State<StudyLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StudyLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _LineChartPainter(
              data: widget.data,
              color: widget.color,
              progress: _animation.value,
            ),
          );
        },
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final double progress;

  _LineChartPainter({
    required this.data,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Days for X-axis
    final days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    // Adjusting for labels
    const double topPadding = 25.0;
    const double bottomPadding = 25.0;
    const double horizontalPadding = 10.0;

    final drawingHeight = size.height - topPadding - bottomPadding;
    final drawingWidth = size.width - (horizontalPadding * 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, drawingHeight))
      ..style = PaintingStyle.fill;

    final maxVal = data
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 1000)
        .toDouble();
    final stepX = drawingWidth / (data.length - 1);

    // Compute all points
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = horizontalPadding + (i * stepX);
      final y = topPadding + drawingHeight - (data[i] / maxVal * drawingHeight);
      points.add(Offset(x, y));
    }

    // Build full path
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
        fillPath.moveTo(points[i].dx, topPadding + drawingHeight);
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final cur = points[i];
        final ctrlX = prev.dx + (cur.dx - prev.dx) / 2;
        path.quadraticBezierTo(ctrlX, prev.dy, ctrlX, (prev.dy + cur.dy) / 2);
        path.quadraticBezierTo(ctrlX, cur.dy, cur.dx, cur.dy);
        fillPath.quadraticBezierTo(
          ctrlX,
          prev.dy,
          ctrlX,
          (prev.dy + cur.dy) / 2,
        );
        fillPath.quadraticBezierTo(ctrlX, cur.dy, cur.dx, cur.dy);
      }
    }

    fillPath.lineTo(
      horizontalPadding + drawingWidth,
      topPadding + drawingHeight,
    );
    fillPath.close();

    // Clip to progress width
    canvas.save();
    final progressWidth = size.width * progress;
    canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points and labels (only up to progress)
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < data.length; i++) {
      final x = points[i].dx;
      final y = points[i].dy;
      if (x > progressWidth) continue;

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 4, pointBorderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i]}',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 18));
    }

    canvas.restore();

    // Day labels (always shown)
    for (int i = 0; i < data.length; i++) {
      final x = horizontalPadding + (i * stepX);
      final dayPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dayPainter.layout();
      dayPainter.paint(
        canvas,
        Offset(x - dayPainter.width / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.data != data;
}
