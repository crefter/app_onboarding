import 'dart:async';

import 'package:app_onboarding/src/app_onboarding.dart';
import 'package:app_onboarding/src/tooltip/app_custom_tooltip.dart';
import 'package:flutter/material.dart';

typedef CustomBuilder = Widget Function(
  BuildContext context,
  int index,
)?;

class TooltipSettings {
  final String? completeText;
  final String skipText;
  final String nextText;
  final String tooltipText;
  final AppCustomArrowPosition arrowPosition;
  final AppCustomTooltipDirection tooltipDirection;
  final FutureOr<void> Function()? onPrevTap;
  final FutureOr<void> Function()? onCompleteTap;
  final FutureOr<void> Function()? onNextTap;

  const TooltipSettings({
    this.tooltipText = 'Text',
    this.skipText = 'Skip',
    this.nextText = 'Next',
    this.arrowPosition = AppCustomArrowPosition.center,
    this.tooltipDirection = AppCustomTooltipDirection.top,
    this.completeText,
    this.onPrevTap,
    this.onCompleteTap,
    this.onNextTap,
  });
}

class AppOnboardingEntry extends StatefulWidget {
  const AppOnboardingEntry({
    super.key,
    required this.child,
    required this.index,
    this.tooltipOffset,
    this.maxWidth = 277,
    this.borderRadius = 10,
    this.enabled = true,
    this.tooltipSettings = const TooltipSettings(),
    this.customTooltipBuilder,
    this.customBackgroundBuilder,
    this.backgroundColor,
  });

  final Widget child;
  final Offset? tooltipOffset;
  final int index;
  final double maxWidth;
  final double borderRadius;
  final TooltipSettings? tooltipSettings;
  final CustomBuilder customTooltipBuilder;
  final CustomBuilder customBackgroundBuilder;
  final Color? backgroundColor;
  final bool enabled;

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
    link = LayerLink();
    gk = GlobalKey();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AppOnboardingEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('a');
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
    final defaultTooltipSettings = widget.tooltipSettings;
    final backgroundColor =
        widget.backgroundColor ?? Colors.black.withOpacity(0.6);

    return OverlayPortal(
      controller: _appOnboardingState.getOverlayController(index),
      overlayChildBuilder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              Positioned.fill(
                // ColoredBox нужен для заполнения всего пространства,
                // чтобы тапы на ui под онбордингом не обрабатывались
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.001),
                  child: CompositedTransformFollower(
                      link: link!,
                      child: CustomPaint(
                        painter: _HolePainter(
                          key: gk!,
                          borderRadius: widget.borderRadius,
                          backgroundColor: backgroundColor,
                        ),
                      )),
                ),
              ),
              if (widget.customBackgroundBuilder != null)
                Positioned.fill(
                  child: widget.customBackgroundBuilder!(context, index),
                ),
              CompositedTransformFollower(
                link: link!,
                targetAnchor: defaultTooltipSettings?.tooltipDirection ==
                        AppCustomTooltipDirection.bottom
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                showWhenUnlinked: false,
                offset: widget.tooltipOffset ??
                    (defaultTooltipSettings?.tooltipDirection ==
                            AppCustomTooltipDirection.top
                        ? const Offset(0, 20)
                        : const Offset(0, -20)),
                followerAnchor: defaultTooltipSettings?.tooltipDirection ==
                        AppCustomTooltipDirection.bottom
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: widget.customTooltipBuilder == null
                      ? _DefaultAnimatedTooltip(
                          arrowPosition:
                              defaultTooltipSettings?.arrowPosition ??
                                  AppCustomArrowPosition.center,
                          tooltipDirection:
                              defaultTooltipSettings?.tooltipDirection ??
                                  AppCustomTooltipDirection.top,
                          onPrevTap: defaultTooltipSettings?.onPrevTap,
                          onCompleteTap: defaultTooltipSettings?.onCompleteTap,
                          onNextTap: defaultTooltipSettings?.onNextTap,
                          completeText: defaultTooltipSettings?.completeText,
                          tooltipText:
                              defaultTooltipSettings?.tooltipText ?? '',
                          hide: _appOnboardingState.hide,
                          show: _appOnboardingState.show,
                          next: _appOnboardingState.next,
                          index: widget.index,
                          stepsLength: _appOnboardingState.stepsLength,
                          nextText: defaultTooltipSettings?.nextText ?? '',
                          skipText: defaultTooltipSettings?.skipText ?? '',
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
    required this.arrowPosition,
    required this.tooltipDirection,
    required this.onPrevTap,
    required this.onCompleteTap,
    required this.onNextTap,
    required this.completeText,
    required this.tooltipText,
    required this.hide,
    required this.show,
    required this.next,
    required this.index,
    required this.stepsLength,
    required this.nextText,
    required this.skipText,
  });

  final AppCustomArrowPosition arrowPosition;
  final AppCustomTooltipDirection tooltipDirection;
  final FutureOr<void> Function()? onPrevTap;
  final FutureOr<void> Function()? onCompleteTap;
  final FutureOr<void> Function()? onNextTap;
  final void Function({bool isDone}) hide;
  final VoidCallback show;
  final VoidCallback next;
  final String? completeText;
  final String tooltipText;
  final String nextText;
  final String skipText;
  final int index;
  final int stepsLength;

  @override
  State<_DefaultAnimatedTooltip> createState() =>
      _DefaultAnimatedTooltipState();
}

class _DefaultAnimatedTooltipState extends State<_DefaultAnimatedTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.5,
    )..forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          direction: widget.tooltipDirection,
          backgroundColor: theme.primaryColor,
          arrowPosition: widget.arrowPosition,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 12,
              left: 12,
              right: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.tooltipText,
                        textAlign: TextAlign.start,
                        maxLines: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.completeText != null)
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onCompleteTap?.call();
                              widget.hide(isDone: true);
                            },
                            child: Text(
                              widget.completeText!,
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
                          onPressed: () {
                            widget.onPrevTap?.call();
                            widget.hide(
                              isDone: true,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.skipText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            widget.hide();
                            await widget.onNextTap?.call();
                            widget.next();
                            widget.show();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${widget.nextText} (${widget.index + 1} / ${widget.stepsLength})'),
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
