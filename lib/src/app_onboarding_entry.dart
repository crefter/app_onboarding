import 'dart:async';

import 'package:app_onboarding/src/app_onboarding.dart';
import 'package:app_onboarding/src/tooltip/app_onboarding_tooltip.dart';
import 'package:flutter/material.dart';

part 'tooltip/default_tooltip.dart';

class ButtonSettings {
  /// Style for default button
  final ButtonStyle? buttonStyle;

  /// Custom builder for button
  final Widget Function(
    String text,
    VoidCallback onTap,
  )? buttonBuilder;

  const ButtonSettings({
    this.buttonStyle,
    this.buttonBuilder,
  });
}

class TooltipTextSettings {
  /// Text inside tooltip
  final String text;

  /// Text style for tooltip text
  final TextStyle? textStyle;

  /// Text align for tooltip text
  final TextAlign textAlign;

  const TooltipTextSettings({
    required this.text,
    this.textAlign = TextAlign.start,
    this.textStyle,
  });
}

class TooltipSettings {
  /// Complete button`s text
  final String? completeText;

  /// Skip button`s text
  final String? skipText;

  final TooltipTextSettings tooltipTextSettings;

  /// Next button`s text
  final String Function(
    int currentIndex,
    int stepsLength,
    int countAutoHidden,
  )? nextText;

  /// Tooltip arrow`s position
  final AppOnboardingTooltipArrowPosition arrowPosition;

  /// Tooltip direction
  final AppOnboardingTooltipDirection tooltipDirection;

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
  final double buttonsGap;

  /// Skip button settings
  final ButtonSettings skipButtonSettings;

  /// Next button settings
  final ButtonSettings nextButtonSettings;

  /// Complete button settings
  final ButtonSettings completeButtonSettings;

  /// Content`s builder for auto hidden tooltip
  final Widget Function(String text)? autoHiddenContentBuilder;
  final Duration? hideAfterDuration;

  const TooltipSettings({
    this.tooltipTextSettings = const TooltipTextSettings(
      text: 'Text in tooltip',
    ),
    this.buttonsGap = 4,
    this.skipText,
    this.nextText,
    this.completeText,
    this.arrowPosition = AppOnboardingTooltipArrowPosition.center,
    this.tooltipDirection = AppOnboardingTooltipDirection.top,
    this.onSkipTap,
    this.onNextTap,
    this.onCompleteTap,
    this.backgroundColor,
    this.padding,
    this.skipButtonSettings = const ButtonSettings(),
    this.nextButtonSettings = const ButtonSettings(),
    this.completeButtonSettings = const ButtonSettings(),
    this.hideAfterDuration,
    this.autoHiddenContentBuilder,
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
    this.holeInnerPadding = 6.0,
    this.enabled = true,
    this.tooltipSettings = const TooltipSettings(),
    this.customTooltipBuilder,
    this.customOverlayBuilder,
    this.backgroundColor,
    this.targetAnchor,
    this.followerAnchor,
    this.onShow,
    this.onHide,
    this.isAutoHidden = false,
    this.hideAfterDuration,
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

  /// Inner padding for hole
  final double holeInnerPadding;

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

  /// If [isAutoHidden] = true, tooltip will hide automatically after [hideAfterDuration].
  /// Use [customTooltipBuilder] to build custom tooltip.
  /// Use [customOverlayBuilder] to build custom overlay.
  /// You can use it after manual onboarding (recommended)
  final bool isAutoHidden;
  final Duration? hideAfterDuration;

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
    var index = widget.index;
    if (widget.isAutoHidden) {
      _appOnboardingState.addAutoHidden(index);
    } else {
      _appOnboardingState.add(index);
    }
    _appOnboardingState.registerOnEntryShow(
      index,
      widget.onShow,
    );
    _appOnboardingState.registerOnEntryHide(
      index,
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

    final isAutoHidden = widget.isAutoHidden;
    final index = widget.index;
    final tooltipSettings = widget.tooltipSettings;
    final backgroundColor =
        widget.backgroundColor ?? Colors.black.withOpacity(0.6);
    final settings = widget.tooltipSettings;

    late Widget child;
    final customTooltipBuilder = widget.customTooltipBuilder;

    if (isAutoHidden) {
      child = customTooltipBuilder?.call(context, index) ??
          _DefaultAnimatedAutoTooltip(
            settings: settings,
            appOnboardingState: _appOnboardingState,
            hideAfterDuration: widget.hideAfterDuration,
          );
    } else {
      child = customTooltipBuilder?.call(context, index) ??
          _DefaultAnimatedTooltip(
            settings: settings,
            appOnboardingState: _appOnboardingState,
            index: widget.index,
          );
    }

    return OverlayPortal(
      controller: _appOnboardingState.getOverlayController(index),
      overlayChildBuilder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              if (!isAutoHidden)
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
                            padding: widget.holeInnerPadding,
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
                            AppOnboardingTooltipDirection.bottom
                        ? Alignment.topCenter
                        : Alignment.bottomCenter),
                showWhenUnlinked: false,
                offset: widget.tooltipOffset ??
                    (tooltipSettings.tooltipDirection ==
                            AppOnboardingTooltipDirection.top
                        ? const Offset(0, 20)
                        : const Offset(0, -20)),
                followerAnchor: widget.followerAnchor ??
                    (tooltipSettings.tooltipDirection ==
                            AppOnboardingTooltipDirection.bottom
                        ? Alignment.bottomCenter
                        : Alignment.topCenter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: child,
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
