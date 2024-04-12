import 'package:app_onboarding/src/app_onboarding.dart';
import 'package:app_onboarding/src/tooltip/app_custom_tooltip.dart';
import 'package:flutter/material.dart';

class TooltipSettings {
  /// Complete button`s text
  final String? completeText;

  /// Skip button`s text
  final String skipText;

  /// Next button`s text
  final String nextText;

  /// Text inside tooltip
  final String tooltipText;

  /// Tooltip arrow`s position
  final AppCustomArrowPosition arrowPosition;

  /// Tooltip direction
  final AppCustomTooltipDirection tooltipDirection;

  /// Callback for skip button. Call before hide [AppOnboardingEntry]
  final FutureVoidCallback? onSkipTap;

  /// Callback for complete button. Call before hide [AppOnboardingEntry]
  final FutureVoidCallback? onCompleteTap;

  /// Callback for next button. Call after hide [AppOnboardingEntry] but before next [AppOnboardingEntry].
  /// You may scroll to next [AppOnboardingEntry] if you need.
  final FutureVoidCallback? onNextTap;

  /// Tooltip background color
  final Color? backgroundColor;

  /// Tooltip inner padding
  final EdgeInsets? padding;

  /// Skip button style
  final ButtonStyle? skipButtonStyle;

  /// Next button style
  final ButtonStyle? nextButtonStyle;

  /// Complete button style
  final ButtonStyle? completeButtonStyle;

  const TooltipSettings({
    this.tooltipText = 'Text in tooltip',
    this.skipText = 'Skip',
    this.nextText = 'Next',
    this.arrowPosition = AppCustomArrowPosition.center,
    this.tooltipDirection = AppCustomTooltipDirection.top,
    this.completeText,
    this.onSkipTap,
    this.onCompleteTap,
    this.onNextTap,
    this.backgroundColor,
    this.padding,
    this.skipButtonStyle,
    this.nextButtonStyle,
    this.completeButtonStyle,
  });
}

class AppOnboardingEntry extends StatefulWidget {
  const AppOnboardingEntry({
    super.key,
    required this.child,
    required this.index,
    this.tooltipOffset,
    this.maxWidth = 277,
    this.holeBorderRadius = 10,
    this.enabled = true,
    this.tooltipSettings = const TooltipSettings(),
    this.customTooltipBuilder,
    this.customOverlayBuilder,
    this.backgroundColor,
    this.targetAnchor,
    this.followerAnchor,
    this.onShow,
    this.onHide,
  });

  final Widget child;

  /// Tootlip offset from center`s [child]
  final Offset? tooltipOffset;

  /// Index for [AppOnboardingEntry]. Defines the display order
  final int index;

  /// maxWidth for default or custom tooltip
  final double maxWidth;

  /// Border radius for hole
  final double holeBorderRadius;

  /// Settings for default tooltip
  final TooltipSettings tooltipSettings;

  /// Builder to do custom tooltip
  final IndexedWidgetBuilder? customTooltipBuilder;

  /// Builder to do custom overlay
  final IndexedWidgetBuilder? customOverlayBuilder;
  final FutureVoidCallback? onShow;
  final FutureVoidCallback? onHide;

  /// Overlay`s background color
  final Color? backgroundColor;

  /// If [enabled] = false, return only [child]
  /// Useful if [child] is a list item
  final bool enabled;
  final Alignment? targetAnchor;
  final Alignment? followerAnchor;

  @override
  State<AppOnboardingEntry> createState() => _AppOnboardingEntryState();
}

class _AppOnboardingEntryState extends State<AppOnboardingEntry> {
  late final AppOnboardingState _appOnboardingState;
  late LayerLink? link;
  late GlobalKey? gk;

  @override
  void didChangeDependencies() {
    _appOnboardingState = AppOnboarding.of(context);
    _appOnboardingState.add(widget.index);
    _appOnboardingState.registerOnEntryShow(
      widget.index,
      widget.onShow,
    );
    _appOnboardingState.registerOnEntryHide(
      widget.index,
      widget.onHide,
    );
    link = LayerLink();
    gk = GlobalKey();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    gk = null;
    link = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final index = widget.index;
    final tooltipSettings = widget.tooltipSettings;
    final backgroundColor =
        widget.backgroundColor ?? Colors.black.withOpacity(0.6);

    return OverlayPortal(
      controller: _appOnboardingState.getOverlayController(index),
      overlayChildBuilder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.001),
                  child: CompositedTransformFollower(
                      link: link!,
                      child: CustomPaint(
                        painter: _HolePainter(
                          key: gk!,
                          borderRadius: widget.holeBorderRadius,
                          backgroundColor: backgroundColor,
                        ),
                      )),
                ),
              ),
              if (widget.customOverlayBuilder != null)
                Positioned.fill(
                  child: widget.customOverlayBuilder!(context, index),
                ),
              CompositedTransformFollower(
                link: link!,
                targetAnchor: widget.targetAnchor ??
                    (tooltipSettings.tooltipDirection ==
                            AppCustomTooltipDirection.bottom
                        ? Alignment.topCenter
                        : Alignment.bottomCenter),
                showWhenUnlinked: false,
                offset: widget.tooltipOffset ??
                    (tooltipSettings.tooltipDirection ==
                            AppCustomTooltipDirection.top
                        ? const Offset(0, 20)
                        : const Offset(0, -20)),
                followerAnchor: widget.followerAnchor ??
                    (tooltipSettings.tooltipDirection ==
                            AppCustomTooltipDirection.bottom
                        ? Alignment.bottomCenter
                        : Alignment.topCenter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: widget.customTooltipBuilder == null
                      ? _DefaultAnimatedTooltip(
                          settings: widget.tooltipSettings,
                          appOnboardingState: _appOnboardingState,
                        )
                      : widget.customTooltipBuilder!(context, index),
                ),
              ),
            ],
          ),
        );
      },
      child: CompositedTransformTarget(
        link: link!,
        key: gk,
        child: widget.child,
      ),
    );
  }
}

class _DefaultAnimatedTooltip extends StatefulWidget {
  const _DefaultAnimatedTooltip({
    required this.settings,
    required this.appOnboardingState,
  });

  final TooltipSettings settings;
  final AppOnboardingState appOnboardingState;

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
        child: AppCustomTooltip(
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
                        settings.tooltipText,
                        textAlign: TextAlign.start,
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
                        child: Material(
                          type: MaterialType.transparency,
                          child: ElevatedButton(
                            style: settings.completeButtonStyle,
                            onPressed: () {
                              settings.onCompleteTap?.call();
                              widget.appOnboardingState.hide(isDone: true);
                            },
                            child: Text(
                              settings.completeText!,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: settings.skipButtonStyle,
                          onPressed: () {
                            settings.onSkipTap?.call();
                            widget.appOnboardingState.hide(
                              isDone: true,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(settings.skipText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton(
                          style: settings.nextButtonStyle,
                          onPressed: () async {
                            widget.appOnboardingState.hide();
                            await settings.onNextTap?.call();
                            widget.appOnboardingState.next();
                            widget.appOnboardingState.show();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${settings.nextText} '
                                '(${widget.appOnboardingState.currentIndex + 1}'
                                ' / '
                                '${widget.appOnboardingState.stepsLength})',
                              ),
                            ],
                          ),
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
}

class _HolePainter extends CustomPainter {
  _HolePainter({
    required this.key,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final double borderRadius;
  final GlobalKey key;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 6.0;
    final paintBack = Paint()..color = backgroundColor;
    final path = Path()..addRect(Rect.largest);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
