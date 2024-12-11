part of '../app_onboarding_entry.dart';

const _defaultHideAfterDuration = Duration(milliseconds: 5000);

class _DefaultAnimatedAutoTooltip extends StatefulWidget {
  const _DefaultAnimatedAutoTooltip({
    required this.settings,
    required this.appOnboardingState,
    this.hideAfterDuration,
  });

  final TooltipSettings settings;
  final AppOnboardingState appOnboardingState;
  final Duration? hideAfterDuration;

  @override
  State<StatefulWidget> createState() => _DefaultAnimatedAutoTooltipState();
}

class _DefaultAnimatedAutoTooltipState
    extends State<_DefaultAnimatedAutoTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final TooltipSettings settings;
  late final Animation<double> fadeTransition;
  late final Animation<double> scaleTransition;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final duration = widget.hideAfterDuration ??
        widget.settings.hideAfterDuration ??
        _defaultHideAfterDuration;
    animationController = AnimationController(
      vsync: this,
      duration: duration,
    )..forward();
    fadeTransition = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 1), weight: 4),
        TweenSequenceItem(tween: ConstantTween(1), weight: 92),
        TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 4),
      ],
    ).animate(animationController);
    scaleTransition = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 1), weight: 4),
        TweenSequenceItem(tween: ConstantTween(1), weight: 92),
        TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.2), weight: 4),
      ],
    ).animate(animationController);
    timer?.cancel();
    timer = Timer(
      duration,
      widget.appOnboardingState.showNext,
    );
    settings = widget.settings;
  }

  @override
  void dispose() {
    animationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = settings.backgroundColor ?? theme.primaryColor;
    final padding = settings.padding ??
        const EdgeInsets.only(
          top: 8,
          bottom: 12,
          left: 12,
          right: 12,
        );
    final tooltipTextSettings = settings.tooltipTextSettings;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: fadeTransition,
        curve: Curves.easeIn,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: scaleTransition,
          curve: Curves.easeIn,
        ),
        child: AppOnboardingTooltip(
          direction: settings.tooltipDirection,
          backgroundColor: backgroundColor,
          arrowPosition: settings.arrowPosition,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: settings.autoHiddenContentBuilder == null
                          ? Text(
                              tooltipTextSettings.text,
                              style: tooltipTextSettings.textStyle,
                              textAlign: tooltipTextSettings.textAlign,
                              maxLines: 50,
                            )
                          : settings.autoHiddenContentBuilder!(
                              tooltipTextSettings.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAnimatedTooltip extends StatefulWidget {
  const _DefaultAnimatedTooltip({
    required this.settings,
    required this.appOnboardingState,
    required this.index,
  });

  final TooltipSettings settings;
  final AppOnboardingState appOnboardingState;
  final int index;

  @override
  State<_DefaultAnimatedTooltip> createState() =>
      _DefaultAnimatedTooltipState();
}

class _DefaultAnimatedTooltipState extends State<_DefaultAnimatedTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final TooltipSettings settings;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.5,
    )..forward();
    settings = widget.settings;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = settings.backgroundColor ?? theme.primaryColor;
    final padding = settings.padding ??
        const EdgeInsets.only(
          top: 8,
          bottom: 12,
          left: 12,
          right: 12,
        );
    var tooltipTextSettings = settings.tooltipTextSettings;
    var completeButtonSettings = settings.completeButtonSettings;
    var skipButtonSettings = settings.skipButtonSettings;
    var nextButtonSettings = settings.nextButtonSettings;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeIn,
        ),
        child: AppOnboardingTooltip(
          direction: settings.tooltipDirection,
          backgroundColor: backgroundColor,
          arrowPosition: settings.arrowPosition,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tooltipTextSettings.text,
                        style: tooltipTextSettings.textStyle,
                        textAlign: tooltipTextSettings.textAlign,
                        maxLines: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (settings.completeText != null)
                  Row(
                    children: [
                      Expanded(
                        child: completeButtonSettings.buttonBuilder == null
                            ? Material(
                                type: MaterialType.transparency,
                                child: ElevatedButton(
                                  style: completeButtonSettings.buttonStyle,
                                  onPressed: _onCompleteTap,
                                  child: Text(
                                    settings.completeText!,
                                  ),
                                ),
                              )
                            : completeButtonSettings.buttonBuilder!(
                                settings.completeText!,
                                _onCompleteTap,
                              ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      if (settings.skipText != null)
                        Expanded(
                          child: skipButtonSettings.buttonBuilder == null
                              ? ElevatedButton(
                                  style: skipButtonSettings.buttonStyle,
                                  onPressed: _onSkipTap,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(settings.skipText!),
                                    ],
                                  ),
                                )
                              : skipButtonSettings.buttonBuilder!(
                                  settings.skipText!,
                                  _onSkipTap,
                                ),
                        ),
                      if (settings.buttonsGap > 0)
                        SizedBox(width: settings.buttonsGap),
                      if (settings.nextText != null)
                        Expanded(
                          child: nextButtonSettings.buttonBuilder == null
                              ? ElevatedButton(
                                  style: nextButtonSettings.buttonStyle,
                                  onPressed: _onNextTap,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        settings.nextText?.call(
                                              widget.index,
                                              widget.appOnboardingState
                                                  .stepsLength,
                                              widget.appOnboardingState
                                                  .countAutoHidden,
                                            ) ??
                                            'Next',
                                      ),
                                    ],
                                  ),
                                )
                              : nextButtonSettings.buttonBuilder!(
                                  settings.nextText?.call(
                                        widget.index,
                                        widget.appOnboardingState.stepsLength,
                                        widget
                                            .appOnboardingState.countAutoHidden,
                                      ) ??
                                      'Next',
                                  _onNextTap,
                                ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCompleteTap() {
    settings.onCompleteTap?.call();
    widget.appOnboardingState.startAutoHidden();
  }

  void _onSkipTap() {
    settings.onSkipTap?.call();
    widget.appOnboardingState.startAutoHidden();
  }

  Future<void> _onNextTap() async {
    widget.appOnboardingState.hide();
    await settings.onNextTap?.call();
    widget.appOnboardingState.next();
    widget.appOnboardingState.show();
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter({
    required this.key,
    required this.backgroundColor,
    required this.borderRadius,
    required this.padding,
  });

  final Color backgroundColor;
  final double borderRadius;
  final double padding;
  final GlobalKey key;

  @override
  void paint(Canvas canvas, Size size) {
    final paintBack = Paint()..color = backgroundColor;
    final path = Path()
      ..addRect(
        Rect.fromPoints(
          Offset(-size.width, -size.height),
          Offset(size.width, size.height),
        ),
      );
    final rect = key.globalPaintBounds!;
    final a = rect.inflate(padding);
    final path2 = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          a,
          Radius.circular(borderRadius),
        ),
      );
    final resPath = Path.combine(PathOperation.difference, path, path2);
    canvas.drawPath(resPath, paintBack);
  }

  @override
  bool shouldRepaint(_HolePainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      borderRadius != oldDelegate.borderRadius ||
      key != oldDelegate.key;
}

extension GlobalKeyEx on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject?.attached ?? false) {
      final translation = renderObject?.getTransformTo(null).getTranslation();
      if (translation != null && renderObject?.paintBounds != null) {
        return renderObject!.paintBounds;
      }
    }
    return null;
  }
}
