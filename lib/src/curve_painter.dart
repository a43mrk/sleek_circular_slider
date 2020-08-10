part of circular_slider;

class _CurvePainter extends CustomPainter {
  final double angle;
  final CircularSliderAppearance appearance;
  final startAngle;
  final angleRange;

  Offset handler;
  Offset center;
  double radius;

  _CurvePainter(
      {this.appearance, this.angle = 30, this.startAngle, this.angleRange})
      : assert(appearance != null),
        assert(startAngle != null),
        assert(angleRange != null);

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) -
        appearance.progressBarWidth * 0.5;
    center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.trackWidth
      ..color = appearance.trackColor;
      // ..color = Colors.grey[200];

    final trackPaint2 = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.trackWidth * 1.04
      ..color = Colors.black38;
    drawCircularArcBorder(
        canvas: canvas,
        size: size,
        paint: trackPaint2,
        ignoreAngle: true,
        spinnerMode: appearance.spinnerMode);
    drawCircularArc(
        canvas: canvas,
        size: size,
        paint: trackPaint,
        ignoreAngle: true,
        spinnerMode: appearance.spinnerMode);

    if (!appearance.hideShadow) {
      // drawShadow(canvas: canvas, size: size);
      drawExtraShadow(canvas: canvas, size: size);
    }

    final progressBarRect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final progressBarGradient = SweepGradient(
      startAngle: degreeToRadians(appearance.gradientStartAngle),
      endAngle: degreeToRadians(appearance.gradientStopAngle),
      tileMode: TileMode.mirror,
      colors: appearance.progressBarColors,
    );

    final progressBarPaint = Paint()
      ..shader = progressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    drawCircularArc(canvas: canvas, size: size, paint: progressBarPaint);

    var dotPaint = Paint()..color = appearance.dotColor;
    var dot2Paint = Paint()..shader = progressBarGradient.createShader(progressBarRect);

    final currentAngle = appearance.counterClockwise ? -angle : angle;

    Offset handler = degreesToCoordinates(
        Offset(size.width / 2 -2, size.height / 2 -2), -math.pi / 2 + startAngle + currentAngle + 1.5, radius - 3);
    Offset handler2 = degreesToCoordinates(
        Offset(size.width / 2 + 1, size.height / 2 + 1), -math.pi / 2 + startAngle + currentAngle + 1.5, radius - 5);
        /// circle at the end of pie
        drawHandlerShadow(canvas: canvas, size: Size.fromRadius(appearance.handlerSize * 1.5), center: handler2);
        canvas.drawArc(Rect.fromCircle(center: handler, radius: appearance.handlerSize * 4), 0, math.pi * 2, false, dotPaint);
        canvas.drawCircle(handler, appearance.handlerSize * 1.5, dot2Paint);
        // canvas.drawCircle(handler, appearance.handlerSize, dotPaint);
  }

  drawCircularArc(
      {@required Canvas canvas,
      @required Size size,
      @required Paint paint,
      bool ignoreAngle = false,
      bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle),
        false,
        paint);
  }

  drawCircularArcBorder(
      {@required Canvas canvas,
      @required Size size,
      @required Paint paint,
      bool ignoreAngle = false,
      bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle),
        false,
        paint );
  }


  drawHandlerShadow({@required Canvas canvas, @required Size size, Offset center}) {
    canvas.translate(size.width/2, size.height/2); 
    Path oval = Path()
        ..addOval(Rect.fromCircle(center: center, radius: size.width));
    Paint shadowPaint = Paint() 
        ..color = Colors.black.withOpacity(0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(oval, shadowPaint);
  }

  drawShadow({@required Canvas canvas, @required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep
        : math.max(
            1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1,
        ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor
          .withOpacity(maxOpacity - (opacityStep * (i - 1)));
      drawCircularArc(canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  drawExtraShadow({@required Canvas canvas, @required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep
        : math.max(
            1, (appearance.shadowWidth - appearance.progressBarWidth) * 5);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1,
        ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(3))
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor
          .withOpacity(maxOpacity - (opacityStep * (i - 0.3)));
      drawCircularArc(canvas: canvas, size: size, paint: shadowPaint, ignoreAngle: true);
    }
  }

  static double convertRadiusToSigma(double radius) {
      return radius * 0.57735 + 0.5;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
